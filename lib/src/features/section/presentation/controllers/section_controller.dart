import 'package:flutter/material.dart';
import '../../data/repositories/section_firestore_repository.dart';
import '../../domain/models/section_item_model.dart';
import '../../domain/models/section_model.dart';
import '../../../design/domain/models/design_model.dart';
import '../../../design/presentation/controllers/design_controller.dart';

/// Customer Section Controller for KC-App.
/// Handles resolution of customer-eligible sections and their resolved designs.
class SectionController extends ChangeNotifier {
  SectionController({
    required String boutiqueId,
    required String branchId,
    required DesignController designController,
    SectionFirestoreRepository? repository,
  })  : _boutiqueId = boutiqueId,
        _branchId = branchId,
        _designController = designController,
        _repository = repository ?? SectionFirestoreRepository();

  final String _boutiqueId;
  final String _branchId;
  final DesignController _designController;
  final SectionFirestoreRepository _repository;

  List<SectionModel> _sections = [];
  final List<SectionItemModel> _sectionItems = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Returns active sections visible for current boutique & branch with at least 1 resolved design.
  List<SectionModel> get visibleSections {
    final now = DateTime.now();
    final list = _sections.where((s) {
      if (!s.isActive) return false;
      if (s.boutiqueId != _boutiqueId) return false;
      if (s.branchId != null && s.branchId != _branchId) return false;
      if (s.startAt != null && now.isBefore(s.startAt!)) return false;
      if (s.endAt != null && now.isAfter(s.endAt!)) return false;
      // Must resolve at least 1 eligible design
      final designs = getDesignsForSection(s);
      return designs.isNotEmpty;
    }).toList();

    list.sort((a, b) {
      final s = a.sortOrder.compareTo(b.sortOrder);
      return s != 0 ? s : a.title.compareTo(b.title);
    });

    return list;
  }

  Future<void> loadSections() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _sections = await _repository.watchSections(_boutiqueId).first;
    } catch (_) {
      _sections = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resolves customer-eligible designs for a given section.
  List<DesignModel> getDesignsForSection(SectionModel section, {int? limit}) {
    List<DesignModel> resolved = [];

    if (section.type == SectionType.manual) {
      final items =
          _sectionItems
              .where((i) => i.sectionId == section.id && i.isActive)
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      for (final item in items) {
        final d = _designController.getDesignById(item.designId);
        if (d != null && !resolved.contains(d)) {
          resolved.add(d);
        }
      }
    } else if (section.type == SectionType.newArrivals) {
      resolved = _designController.getRecentDesigns(limit: 20);
    } else if (section.type == SectionType.recommended) {
      final all = _designController.visibleDesigns;
      final tagged = all
          .where(
            (d) => d.tags.any(
              (t) =>
                  t.contains('featured') ||
                  t.contains('popular') ||
                  t.contains('recommended'),
            ),
          )
          .toList();
      resolved = tagged.isNotEmpty ? tagged : all;
    }

    if (limit != null && resolved.length > limit) {
      return resolved.take(limit).toList();
    }
    return resolved;
  }
}
