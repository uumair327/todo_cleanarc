import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/core/utils/memory_manager.dart';
import 'package:todo_cleanarc/core/theme/app_durations.dart';

void main() {
  group('MemoryManager Enhanced Caching Tests', () {
    late MemoryManager manager;

    setUp(() {
      manager = MemoryManager(maxCacheSize: 100);
    });

    tearDown(() {
      manager.dispose();
    });

    test('Cache item and retrieve successfully', () {
      manager.cacheItem('key1', 'value1');
      
      final result = manager.getCachedItem<String>('key1');
      
      expect(result, equals('value1'));
    });

    test('Cache miss returns null', () {
      final result = manager.getCachedItem<String>('nonexistent');
      
      expect(result, isNull);
    });

    test('Expired items are not returned', () async {
      manager.cacheItem('key1', 'value1', ttl: const Duration(milliseconds: 100));
      
      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 150));
      
      final result = manager.getCachedItem<String>('key1');
      
      expect(result, isNull);
    });

    test('LRU eviction when cache is full', () {
      // Fill cache to max
      for (int i = 0; i < 100; i++) {
        manager.cacheItem('key$i', 'value$i');
      }
      
      // Add one more item, should evict oldest
      manager.cacheItem('key100', 'value100');
      
      // First item should be evicted
      expect(manager.getCachedItem<String>('key0'), isNull);
      // Last item should exist
      expect(manager.getCachedItem<String>('key100'), equals('value100'));
    });

    test('Cache groups allow selective invalidation', () {
      manager.cacheItem('task1', 'value1', group: 'tasks');
      manager.cacheItem('task2', 'value2', group: 'tasks');
      manager.cacheItem('user1', 'value3', group: 'users');
      
      // Clear only tasks group
      manager.clearCacheGroup('tasks');
      
      expect(manager.getCachedItem<String>('task1'), isNull);
      expect(manager.getCachedItem<String>('task2'), isNull);
      expect(manager.getCachedItem<String>('user1'), equals('value3'));
    });

    test('Pattern-based invalidation works correctly', () {
      manager.cacheItem('task_1', 'value1');
      manager.cacheItem('task_2', 'value2');
      manager.cacheItem('user_1', 'value3');
      
      // Invalidate all task keys
      manager.invalidatePattern((key) => key.startsWith('task_'));
      
      expect(manager.getCachedItem<String>('task_1'), isNull);
      expect(manager.getCachedItem<String>('task_2'), isNull);
      expect(manager.getCachedItem<String>('user_1'), equals('value3'));
    });

    test('Cache warming populates cache efficiently', () {
      final items = {
        'key1': 'value1',
        'key2': 'value2',
        'key3': 'value3',
      };
      
      manager.warmCache(items, group: 'preloaded');
      
      expect(manager.getCachedItem<String>('key1'), equals('value1'));
      expect(manager.getCachedItem<String>('key2'), equals('value2'));
      expect(manager.getCachedItem<String>('key3'), equals('value3'));
    });

    test('Hit rate is calculated correctly', () {
      manager.resetStats();
      
      manager.cacheItem('key1', 'value1');
      manager.cacheItem('key2', 'value2');
      
      // 2 hits
      manager.getCachedItem<String>('key1');
      manager.getCachedItem<String>('key2');
      
      // 1 miss
      manager.getCachedItem<String>('key3');
      
      final stats = manager.getCacheStats();
      
      expect(stats.hits, equals(2));
      expect(stats.misses, equals(1));
      expect(stats.hitRate, closeTo(0.666, 0.01));
    });

    test('Cache statistics are accurate', () {
      manager.resetStats();
      
      // Add items
      for (int i = 0; i < 10; i++) {
        manager.cacheItem('key$i', 'value$i', group: 'test');
      }
      
      // Access some items
      manager.getCachedItem<String>('key0');
      manager.getCachedItem<String>('key1');
      manager.getCachedItem<String>('nonexistent');
      
      final stats = manager.getCacheStats();
      
      expect(stats.totalItems, equals(10));
      expect(stats.hits, equals(2));
      expect(stats.misses, equals(1));
      expect(stats.groups, equals(1));
    });

    test('ContainsKey does not affect LRU order', () {
      manager.cacheItem('key1', 'value1');
      manager.cacheItem('key2', 'value2');
      
      // Check existence without affecting LRU
      expect(manager.containsKey('key1'), isTrue);
      expect(manager.containsKey('nonexistent'), isFalse);
      
      // Stats should not be affected
      final stats = manager.getCacheStats();
      expect(stats.hits, equals(0));
      expect(stats.misses, equals(0));
    });

    test('Automatic cleanup removes expired items', () async {
      final shortLivedManager = MemoryManager(
        maxCacheSize: 100,
        cleanupInterval: const Duration(milliseconds: 200),
      );
      
      // Add items with short TTL
      shortLivedManager.cacheItem('key1', 'value1', 
        ttl: const Duration(milliseconds: 100));
      shortLivedManager.cacheItem('key2', 'value2', 
        ttl: const Duration(seconds: 10));
      
      // Wait for cleanup to run
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Expired item should be gone
      expect(shortLivedManager.getCachedItem<String>('key1'), isNull);
      // Non-expired item should still exist
      expect(shortLivedManager.getCachedItem<String>('key2'), equals('value2'));
      
      shortLivedManager.dispose();
    });

    test('Cache eviction tracking works correctly', () {
      manager.resetStats();
      
      // Fill cache beyond capacity
      for (int i = 0; i < 110; i++) {
        manager.cacheItem('key$i', 'value$i');
      }
      
      final stats = manager.getCacheStats();
      
      // Should have evicted 10 items
      expect(stats.evictions, equals(10));
      expect(stats.totalItems, equals(100));
    });

    test('Multiple groups can coexist', () {
      manager.cacheItem('task1', 'value1', group: 'tasks');
      manager.cacheItem('task2', 'value2', group: 'tasks');
      manager.cacheItem('user1', 'value3', group: 'users');
      manager.cacheItem('setting1', 'value4', group: 'settings');
      
      final stats = manager.getCacheStats();
      expect(stats.groups, equals(3));
      
      // Clear one group
      manager.clearCacheGroup('tasks');
      
      final statsAfter = manager.getCacheStats();
      expect(statsAfter.groups, equals(2));
      expect(statsAfter.totalItems, equals(2));
    });

    test('Cache utilization rate is calculated correctly', () {
      // Add 50 items to cache with max 100
      for (int i = 0; i < 50; i++) {
        manager.cacheItem('key$i', 'value$i');
      }
      
      final stats = manager.getCacheStats();
      
      expect(stats.utilizationRate, equals(0.5));
    });
  });
}
