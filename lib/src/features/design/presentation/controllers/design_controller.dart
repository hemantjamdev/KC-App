import 'package:flutter/material.dart';
import '../../data/repositories/design_firestore_repository.dart';
import '../../domain/models/design_availability_model.dart';
import '../../domain/models/design_model.dart';

/// Read-only customer design controller for KC-App.
/// Exposes only customer-eligible designs. No CRUD operations.
class DesignController extends ChangeNotifier {
  DesignController({
    required String boutiqueId,
    required this.branchId,
    required List<String> activeCategoryIds,
    DesignFirestoreRepository? repository,
  })  : _boutiqueId = boutiqueId,
        _activeCategoryIds = activeCategoryIds,
        _repository = repository ?? DesignFirestoreRepository();

  final String _boutiqueId;
  final String branchId;
  final List<String> _activeCategoryIds;
  final DesignFirestoreRepository _repository;

  List<DesignModel> _eligibleDesigns = [];
  final List<DesignAvailabilityModel> _availability = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategoryId;

  List<DesignAvailabilityModel> get availabilityRecords =>
      List.unmodifiable(_availability);

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Customer-eligible designs after search + category filter.
  List<DesignModel> get visibleDesigns {
    var results = _eligibleDesigns.where((d) {
      if (_selectedCategoryId != null && d.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final inName = d.name.toLowerCase().contains(q);
        final inSlug = d.slug.toLowerCase().contains(q);
        final inTags = d.tags.any((t) => t.toLowerCase().contains(q));
        final inKeywords = d.searchKeywords.any(
          (k) => k.toLowerCase().contains(q),
        );
        if (!inName && !inSlug && !inTags && !inKeywords) return false;
      }
      return true;
    }).toList();
    return results;
  }

  /// Designs for a specific category (customer-eligible only).
  List<DesignModel> getDesignsForCategory(String categoryId) {
    return _eligibleDesigns.where((d) => d.categoryId == categoryId).toList();
  }

  /// Recently added eligible designs sorted by newest createdAt, capped at [limit].
  List<DesignModel> getRecentDesigns({int limit = 6}) {
    final sorted = List<DesignModel>.from(_eligibleDesigns)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  int get totalCount => _eligibleDesigns.length;

  Future<void> loadDesigns() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final allDesigns = await _repository.watchDesigns(_boutiqueId).first;
      _eligibleDesigns = allDesigns.where((d) {
        if (!d.isActive) return false;
        if (_activeCategoryIds.isNotEmpty &&
            !_activeCategoryIds.contains(d.categoryId)) {
          return false;
        }
        return true;
      }).toList();
    } catch (_) {
      _eligibleDesigns = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchDesigns(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    notifyListeners();
  }

  void filterByCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  DesignModel? getDesignById(String designId) {
    try {
      return _eligibleDesigns.firstWhere((d) => d.id == designId);
    } catch (_) {
      return null;
    }
  }
}
