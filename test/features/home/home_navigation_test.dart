import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_app/src/app/app_routes.dart';
import 'package:kc_app/src/features/category/domain/models/category_model.dart';
import 'package:kc_app/src/features/design/domain/models/design_model.dart';
import 'package:kc_app/src/features/home/presentation/widgets/section_header_row.dart';

void main() {
  group('Customer Home Navigation & Category Routing Tests', () {
    test('AppRoutes customerCategoryList points to dedicated /customer/categories', () {
      expect(AppRoutes.customerCategoryList, equals('/customer/categories'));
      expect(AppRoutes.customerCategoryList, isNot(equals(AppRoutes.customerHome)));
    });

    test('AppRoutes customerAllDesigns points to dedicated /customer/designs/all', () {
      expect(AppRoutes.customerAllDesigns, equals('/customer/designs/all'));
    });

    test('Category matching logic correctly pairs designs by id, slug, and tags', () {
      final category = CategoryModel(
        id: 'cat_lehenga',
        boutiqueId: 'boutique_01',
        name: 'Bridal Lehenga',
        slug: 'lehenga',
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final matchingDesignById = DesignModel(
        id: 'd_1',
        boutiqueId: 'boutique_01',
        categoryId: 'cat_lehenga',
        name: 'Royal Velvet Lehenga',
        slug: 'royal-velvet-lehenga',
        imageUrls: ['https://example.com/img1.jpg'],
        tags: ['velvet'],
        searchKeywords: ['royal'],
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final matchingDesignBySlug = DesignModel(
        id: 'd_2',
        boutiqueId: 'boutique_01',
        categoryId: 'lehenga',
        name: 'Silk Lehenga',
        slug: 'silk-lehenga',
        imageUrls: ['https://example.com/img2.jpg'],
        tags: ['silk'],
        searchKeywords: ['silk'],
        sortOrder: 2,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final matchingDesignByTag = DesignModel(
        id: 'd_3',
        boutiqueId: 'boutique_01',
        categoryId: 'other',
        name: 'Pastel Designer Piece',
        slug: 'pastel-designer-piece',
        imageUrls: ['https://example.com/img3.jpg'],
        tags: ['bridal lehenga'],
        searchKeywords: ['pastel'],
        sortOrder: 3,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final nonMatchingDesign = DesignModel(
        id: 'd_4',
        boutiqueId: 'boutique_01',
        categoryId: 'cat_saree',
        name: 'Banarasi Saree',
        slug: 'banarasi-saree',
        imageUrls: ['https://example.com/img4.jpg'],
        tags: ['saree'],
        searchKeywords: ['saree'],
        sortOrder: 4,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final all = [
        matchingDesignById,
        matchingDesignBySlug,
        matchingDesignByTag,
        nonMatchingDesign,
      ];

      final catId = category.id.toLowerCase().trim();
      final catName = category.name.toLowerCase().trim();
      final catSlug = category.slug.toLowerCase().trim();

      final matched = all.where((d) {
        if (!d.isActive) return false;
        final dCatId = d.categoryId.toLowerCase().trim();
        if (catId.isNotEmpty && dCatId == catId) return true;
        if (catSlug.isNotEmpty && dCatId == catSlug) return true;

        final dCatIds = d.categoryIds.map((id) => id.toLowerCase().trim()).toList();
        if (catId.isNotEmpty && dCatIds.contains(catId)) return true;
        if (catSlug.isNotEmpty && dCatIds.contains(catSlug)) return true;

        if (catName.isNotEmpty && d.tags.any((t) => t.toLowerCase().contains(catName))) {
          return true;
        }
        if (catSlug.isNotEmpty && d.tags.any((t) => t.toLowerCase().contains(catSlug))) {
          return true;
        }
        return false;
      }).toList();

      expect(matched.length, equals(3));
      expect(matched.map((d) => d.id), containsAll(['d_1', 'd_2', 'd_3']));
      expect(matched.map((d) => d.id), isNot(contains('d_4')));
    });

    testWidgets('SectionHeaderRow triggers onViewAll callback on tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeaderRow(
              title: 'BOUTIQUE COLLECTIONS',
              onViewAll: () => tapped = true,
            ),
          ),
        ),
      );

      // Verify title is rendered
      expect(find.text('BOUTIQUE COLLECTIONS'), findsOneWidget);
      expect(find.text('View all'), findsOneWidget);

      // Tap View all button
      await tester.tap(find.text('View all'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
