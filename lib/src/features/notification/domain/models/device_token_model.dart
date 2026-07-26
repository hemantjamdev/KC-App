import 'package:flutter/foundation.dart';

@immutable
class DeviceTokenModel {
  const DeviceTokenModel({
    required this.id,
    required this.customerId,
    this.firebaseUid,
    required this.token,
    this.platform = 'android',
    this.deviceId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.lastSeenAt,
  });

  final String id;
  final String customerId;
  final String? firebaseUid;
  final String token;
  final String platform;
  final String? deviceId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastSeenAt;
}
