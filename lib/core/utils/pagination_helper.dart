import 'dart:math';

/// Helper class for managing pagination in large datasets
class PaginationHelper {
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  final int pageSize;
  int _currentPage = 0;
  bool _hasMoreData = true;
  
  PaginationHelper({this.pageSize = defaultPageSize}) 
    : assert(pageSize > 0 && pageSize <= maxPageSize, 
        'Page size must be between 1 and $maxPageSize');

  /// Get the current page number (0-based)
  int get currentPage => _currentPage;
  
  /// Check if there's more data to load
  bool get hasMoreData => _hasMoreData;
  
  /// Get the offset for the current page
  int get offset => _currentPage * pageSize;
  
  /// Get the limit for the current page
  int get limit => pageSize;
  
  /// Move to the next page
  void nextPage() {
    if (_hasMoreData) {
      _currentPage++;
    }
  }
  
  /// Reset pagination to the first page
  void reset() {
    _currentPage = 0;
    _hasMoreData = true;
  }
  
  /// Update pagination state based on received data
  void updateState(int receivedCount) {
    _hasMoreData = receivedCount >= pageSize;
  }
  
  /// Calculate total pages for a given total count
  int calculateTotalPages(int totalCount) {
    return (totalCount / pageSize).ceil();
  }
  
  /// Get page info for display
  String getPageInfo(int totalCount) {
    final totalPages = calculateTotalPages(totalCount);
    final startItem = min(offset + 1, totalCount);
    final endItem = min(offset + pageSize, totalCount);
    
    return 'Showing $startItem-$endItem of $totalCount items (Page ${_currentPage + 1} of $totalPages)';
  }
}

/// Pagination result wrapper
class PaginatedResult<T> {
  final List<T> data;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
  final int pageSize;
  
  const PaginatedResult({
    required this.data,
    required this.totalCount,
    required this.hasMore,
    required this.currentPage,
    required this.pageSize,
  });
  
  /// Create an empty result
  factory PaginatedResult.empty() {
    return const PaginatedResult(
      data: [],
      totalCount: 0,
      hasMore: false,
      currentPage: 0,
      pageSize: 0,
    );
  }
  
  /// Check if this is the first page
  bool get isFirstPage => currentPage == 0;
  
  /// Check if this is the last page
  bool get isLastPage => !hasMore;
  
  /// Get total number of pages
  int get totalPages => totalCount > 0 ? (totalCount / pageSize).ceil() : 0;
}