import 'package:flutter/material.dart';
import '../../data/repositories/category_firestore_repository.dart';
import '../../domain/models/category_model.dart';

/// Read-oriented category controller for KC-App.
/// Exposes only browsing/search. No CRUD operations.
class CategoryController extends ChangeNotifier {
  CategoryController({
    required String boutiqueId,
    CategoryFirestoreRepository? repository,
  })  : _boutiqueId = boutiqueId,
        _repository = repository ?? CategoryFirestoreRepository();

  final String _boutiqueId;
  final CategoryFirestoreRepository _repository;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  /// Active categories after search filter applied.
  List<CategoryModel> get visibleCategories {
    if (_searchQuery.isEmpty) return List.unmodifiable(_categories);
    final q = _searchQuery.toLowerCase();
    return _categories
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.slug.toLowerCase().contains(q),
        )
        .toList();
  }

  int get totalCount => _categories.length;

  Future<void> loadCategories() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _repository.watchCategories(_boutiqueId).first;
      _categories = list.where((c) => c.isActive).toList();
    } catch (_) {
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchCategories(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }
}
