import 'package:flutter/foundation.dart';
import '../../../design/domain/models/design_model.dart';

/// Immutable state for paginated trending listing screen.
@immutable
class TrendingPageState {
  const TrendingPageState({
    this.items = const [],
    this.page = 1,
    this.pageSize = 8,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<DesignModel> items;
  final int page;
  final int pageSize;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  TrendingPageState copyWith({
    List<DesignModel>? items,
    int? page,
    int? pageSize,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TrendingPageState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrendingPageState &&
        listEquals(other.items, items) &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.hasMore == hasMore &&
        other.isLoading == isLoading &&
        other.isLoadingMore == isLoadingMore &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(items),
    page,
    pageSize,
    hasMore,
    isLoading,
    isLoadingMore,
    errorMessage,
  );
}
