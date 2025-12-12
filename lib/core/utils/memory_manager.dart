import 'dart:async';
import 'dart:collection';

/// Memory management utilities for handling large datasets
class MemoryManager {
  static const int _defaultCacheSize = 1000;
  static const Duration _defaultCleanupInterval = Duration(minutes: 5);
  
  final int maxCacheSize;
  final Duration cleanupInterval;
  final LinkedHashMap<String, _CacheEntry> _cache = LinkedHashMap();
  Timer? _cleanupTimer;
  
  MemoryManager({
    this.maxCacheSize = _defaultCacheSize,
    this.cleanupInterval = _defaultCleanupInterval,
  }) {
    _startCleanupTimer();
  }
  
  /// Cache an item with automatic cleanup
  void cacheItem<T>(String key, T item, {Duration? ttl}) {
    final entry = _CacheEntry(
      item,
      DateTime.now(),
      ttl ?? const Duration(minutes: 30),
    );
    
    _cache[key] = entry;
    
    // Remove oldest items if cache is full
    while (_cache.length > maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
  }
  
  /// Retrieve cached item
  T? getCachedItem<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    // Check if expired
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    // Move to end (LRU)
    _cache.remove(key);
    _cache[key] = entry;
    
    return entry.item as T?;
  }
  
  /// Remove item from cache
  void removeCachedItem(String key) {
    _cache.remove(key);
  }
  
  /// Clear all cached items
  void clearCache() {
    _cache.clear();
  }
  
  /// Get cache statistics
  CacheStats getCacheStats() {
    final now = DateTime.now();
    int expiredCount = 0;
    
    for (final entry in _cache.values) {
      if (entry.isExpired) expiredCount++;
    }
    
    return CacheStats(
      totalItems: _cache.length,
      expiredItems: expiredCount,
      maxSize: maxCacheSize,
      hitRate: _calculateHitRate(),
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
      _cache.remove(key);
    }
  }
  
  /// Calculate cache hit rate (simplified)
  double _calculateHitRate() {
    // This is a simplified calculation
    // In a real implementation, you'd track hits and misses
    return _cache.isNotEmpty ? 0.8 : 0.0;
  }
  
  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

/// Cache entry with expiration
class _CacheEntry {
  final dynamic item;
  final DateTime createdAt;
  final Duration ttl;
  
  _CacheEntry(this.item, this.createdAt, this.ttl);
  
  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}

/// Cache statistics
class CacheStats {
  final int totalItems;
  final int expiredItems;
  final int maxSize;
  final double hitRate;
  
  const CacheStats({
    required this.totalItems,
    required this.expiredItems,
    required this.maxSize,
    required this.hitRate,
  });
  
  int get activeItems => totalItems - expiredItems;
  double get utilizationRate => totalItems / maxSize;
  
  @override
  String toString() {
    return 'CacheStats(active: $activeItems/$maxSize, '
           'expired: $expiredItems, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}

/// Global memory manager instance
final memoryManager = MemoryManager();