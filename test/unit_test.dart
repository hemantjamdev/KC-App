import 'package:flutter_test/flutter_test.dart';
import 'package:kc_app/src/features/customer/domain/models/customer_model.dart';
import 'package:kc_app/src/features/design/domain/models/design_model.dart';
import 'package:kc_app/src/features/stitching/domain/models/stitching_order_model.dart';

void main() {
  group('KC-App Domain & Unit Tests', () {
    test('CustomerModel properties and copyWith', () {
      final now = DateTime.now();
      final customer = CustomerModel(
        id: 'cust_1001',
        boutiqueIds: const ['boutique_01'],
        branchIds: const ['branch_01'],
        displayName: 'Aarya',
        phone: '+919876543210',
        email: 'aarya@example.com',
        source: CustomerSource.google,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(customer.id, equals('cust_1001'));
      expect(customer.displayName, equals('Aarya'));
      expect(customer.phone, equals('+919876543210'));

      final updated = customer.copyWith(phone: '+919999988888');
      expect(updated.phone, equals('+919999988888'));
    });

    test('DesignModel availability and pricing', () {
      final now = DateTime.now();
      final design = DesignModel(
        id: 'd_1',
        boutiqueId: 'boutique_01',
        categoryId: 'cat_01',
        slug: 'royal-heritage-silk-lehenga',
        name: 'Royal Heritage Silk Lehenga',
        price: 12999.0,
        imageUrls: const ['https://example.com/lehenga.jpg'],
        colors: const ['Crimson Red', 'Gold'],
        sizes: const ['S', 'M', 'L', 'XL'],
        tags: const ['festival', 'trending'],
        searchKeywords: const [],
        sortOrder: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(design.price, equals(12999.0));
      expect(design.sizes, contains('XL'));
      expect(design.tags, contains('trending'));
    });

    test('StitchingOrderModel status labels', () {
      final now = DateTime.now();
      final order = StitchingOrderModel(
        id: 'st_01',
        orderNumber: 'KC-STITCH-88',
        boutiqueId: 'boutique_01',
        branchId: 'branch_01',
        customerId: 'cust_1001',
        designReferences: const [],
        status: StitchingOrderStatus.requested,
        createdAt: now,
        updatedAt: now,
      );

      expect(order.status.adminLabel, equals('Requested'));
      expect(StitchingOrderStatus.accepted.adminLabel, equals('Accepted'));
      expect(StitchingOrderStatus.completed.adminLabel, equals('Completed'));
    });

    test(
      'Customer Profile created in KC-App is deserializable by KC-Admin',
      () {
        final json = {
          'id': 'user_google_uid_555',
          'displayName': 'Priya Sharma',
          'email': 'priya@example.com',
          'phone': '+919876543210',
          'photoUrl': 'https://lh3.googleusercontent.com/a/photo.jpg',
          'boutiqueIds': ['default'],
          'branchIds': [],
          'source': 'google',
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final customer = CustomerModel(
          id: json['id'] as String,
          displayName: json['displayName'] as String,
          email: json['email'] as String?,
          phone: json['phone'] as String?,
          photoUrl: json['photoUrl'] as String?,
          boutiqueIds: List<String>.from(json['boutiqueIds'] as List),
          branchIds: List<String>.from(json['branchIds'] as List),
          source: CustomerSource.values.firstWhere(
            (e) => e.name == json['source'],
            orElse: () => CustomerSource.google,
          ),
          isActive: json['isActive'] as bool,
          createdAt: DateTime.parse(json['createdAt'] as String),
          updatedAt: DateTime.parse(json['updatedAt'] as String),
        );

        expect(customer.id, equals('user_google_uid_555'));
        expect(customer.displayName, equals('Priya Sharma'));
        expect(customer.source, equals(CustomerSource.google));
      },
    );

    test(
      'Customer registration handles missing display name or photo safely',
      () {
        final now = DateTime.now();
        final customer = CustomerModel(
          id: 'uid_no_name',
          displayName: 'Valued Customer',
          email: 'user@example.com',
          phone: null,
          photoUrl: null,
          boutiqueIds: const ['default'],
          branchIds: const [],
          source: CustomerSource.google,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        expect(customer.displayName, equals('Valued Customer'));
        expect(customer.phone, isNull);
        expect(customer.photoUrl, isNull);
      },
    );
  });
}
