import 'package:flutter/foundation.dart';

/// Immutable domain model representing a Boutique / Studio.
@immutable
class BoutiqueModel {
  const BoutiqueModel({
    required this.id,
    required this.name,
    required this.subtitle,
    this.phone,
    this.email,
    this.address,
    this.openingHours,
    this.description,
    this.logoUrl,
    required this.isActive,
  });

  final String id;
  final String name;
  final String subtitle;
  final String? phone;
  final String? email;
  final String? address;
  final String? openingHours;
  final String? description;
  final String? logoUrl;
  final bool isActive;

  BoutiqueModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? phone,
    String? email,
    String? address,
    String? openingHours,
    String? description,
    String? logoUrl,
    bool? isActive,
  }) {
    return BoutiqueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      openingHours: openingHours ?? this.openingHours,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BoutiqueModel &&
        other.id == id &&
        other.name == name &&
        other.subtitle == subtitle &&
        other.phone == phone &&
        other.email == email &&
        other.address == address &&
        other.openingHours == openingHours &&
        other.description == description &&
        other.logoUrl == logoUrl &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      subtitle,
      phone,
      email,
      address,
      openingHours,
      description,
      logoUrl,
      isActive,
    );
  }

  @override
  String toString() {
    return 'BoutiqueModel(id: $id, name: $name, subtitle: $subtitle, phone: $phone, email: $email, address: $address, openingHours: $openingHours, description: $description, logoUrl: $logoUrl, isActive: $isActive)';
  }
}
