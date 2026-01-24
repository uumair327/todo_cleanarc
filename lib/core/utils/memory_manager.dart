import 'dart:async';
import 'dart:collection';
import '../theme/app_durations.dart';

/// Memory management utilities for handling large datasets
class MemoryManager {
  static const int _defaultCacheSize = 1000;
  static const Duration _defaultCleanupInterval = AppDurations.cacheMedium;

  final int maxCacheSize;
  final Duration cleanupInterval;
  final LinkedHashMap<String, _CacheEntry> _cache = LinkedHashMap();
  final Map<String, Set<String>> _cacheGroups = {};
  Timer? _cleanupTimer;
  
  // Hit/miss tracking for accurate statistics
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;

  MemoryManager({
    this.maxCacheSize = _defaultCacheSize,
    this.cleanupInterval = _defaultCleanupInterval,
  }) {
    _startCleanupTimer();
  }

  /// Cache an item with automatic cleanup and optional grouping
  void cacheItem<T>(String key, T item, {Duration? ttl, String? group}) {
    final entry = _CacheEntry(
      item,
      DateTime.now(),
      ttl ?? AppDurations.cacheLong,
      group: group,
    );

    _cache[key] = entry;
    
    // Add to group if specified
    if (group != null) {
      _cacheGroups.putIfAbsent(group, () => {});
      _cacheGroups[group]!.add(key);
    }

    // Remove oldest items if cache is full (LRU eviction)
    while (_cache.length > maxCacheSize) {
      final oldestKey = _cache.keys.first;
      final oldestEntry = _cache[oldestKey];
      
      // Remove from group if it belongs to one
      if (oldestEntry?.group != null) {
        _cacheGroups[oldestEntry!.group]?.remove(oldestKey);
      }
      
      _cache.remove(oldestKey);
      _evictions++;
    }
  }

  /// Retrieve cached item with hit/miss tracking
  T? getCachedItem<T>(String key) {
    final entry = _cache[key];
    if (entry == null) {
      _misses++;
      return null;
    }

    // Check if expired
    if (entry.isExpired) {
      _cache.remove(key);
      if (entry.group != null) {
        _cacheGroups[entry.group]?.remove(key);
      }
      _misses++;
      return null;
    }

    // Move to end (LRU)
    _cache.remove(key);
    _cache[key] = entry;
    _hits++;

    return entry.item as T?;
  }

  /// Remove item from cache
  void removeCachedItem(String key) {
    final entry = _cache[key];
    if (entry?.group != null) {
      _cacheGroups[entry!.group]?.remove(key);
    }
    _cache.remove(key);
  }

  /// Clear all cached items
  void clearCache() {
    _cache.clear();
    _cacheGroups.clear();
  }
  
  /// Clear cache by group (selective invalidation)
  void clearCacheGroup(String group) {
    final keys = _cacheGroups[group];
    if (keys != null) {
      for (final key in keys.toList()) {
        _cache.remove(key);
      }
      _cacheGroups.remove(group);
    }
  }
  
  /// Invalidate cache entries matching a pattern
  void invalidatePattern(bool Function(String key) matcher) {
    final keysToRemove = <String>[];
    
    for (final key in _cache.keys) {
      if (matcher(key)) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      removeCachedItem(key);
    }
  }
  
  /// Warm up cache with frequently accessed items
  void warmCache<T>(Map<String, T> items, {Duration? ttl, String? group}) {
    for (final entry in items.entries) {
      cacheItem(entry.key, entry.value, ttl: ttl, group: group);
    }
  }
  
  /// Check if cache contains a key (without affecting LRU)
  bool containsKey(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      if (entry.group != null) {
        _cacheGroups[entry.group]?.remove(key);
      }
      return false;
    }
    return true;
  }

  /// Get cache statistics
  CacheStats getCacheStats() {
    int expiredCount = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired) expiredCount++;
    }

    return CacheStats(
      totalItems: _cache.length,
      expiredItems: expiredCount,
      maxSize: maxCacheSize,
      hitRate: _calculateHitRate(),
      hits: _hits,
      misses: _misses,
      evictions: _evictions,
      groups: _cacheGroups.length,
    );
  }

  /// Start automatic cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) => _cleanup());
  }

  /// Clean up expired items
  void _cleanup() {
    final keysToRemove = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      final entry = _cache[key];
      if (entry?.group != null) {
        _cacheGroups[entry!.group]?.remove(key);
      }
      _cache.remove(key);
    }
  }

  /// Calculate cache hit rate
  double _calculateHitRate() {
    final total = _hits + _misses;
    if (total == 0) return 0.0;
    return _hits / total;
  }
  
  /// Reset statistics
  void resetStats() {
    _hits = 0;
    _misses = 0;
    _evictions = 0;
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    _cacheGroups.clear();
  }
}

/// Cache entry with expiration and grouping
class _CacheEntry {
  final dynamic item;
  final DateTime createdAt;
  final Duration ttl;
  final String? group;

  _CacheEntry(this.item, this.createdAt, this.ttl, {this.group});

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}

/// Cache statistics
class CacheStats {
  final int totalItems;
  final int expiredItems;
  final int maxSize;
  final double hitRate;
  final int hits;
  final int misses;
  final int evictions;
  final int groups;

  const CacheStats({
    required this.totalItems,
    required this.expiredItems,
    required this.maxSize,
    required this.hitRate,
    required this.hits,
    required this.misses,
    required this.evictions,
    required this.groups,
  });

  int get activeItems => totalItems - expiredItems;
  double get utilizationRate => totalItems / maxSize;

  @override
  String toString() {
    return 'CacheStats(active: $activeItems/$maxSize, '
        'expired: $expiredItems, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
        'hits: $hits, misses: $misses, evictions: $evictions, groups: $groups)';
  }
}

/// Global memory manager instance
final memoryManager = MemoryManager();
