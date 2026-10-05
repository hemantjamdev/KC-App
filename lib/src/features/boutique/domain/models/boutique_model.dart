import 'package:flutter/foundation.dart';

/// Domain class representing operating schedule for a single day of the week.
@immutable
class DayOperatingSchedule {
  const DayOperatingSchedule({
    required this.day,
    required this.isOpen,
    this.openTime = '10:00 AM',
    this.closeTime = '08:30 PM',
  });

  final String day;
  final bool isOpen;
  final String openTime;
  final String closeTime;

  DayOperatingSchedule copyWith({
    String? day,
    bool? isOpen,
    String? openTime,
    String? closeTime,
  }) {
    return DayOperatingSchedule(
      day: day ?? this.day,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  factory DayOperatingSchedule.fromMap(Map<String, dynamic> map, String defaultDay) {
    return DayOperatingSchedule(
      day: map['day'] as String? ?? defaultDay,
      isOpen: map['isOpen'] as bool? ?? true,
      openTime: map['openTime'] as String? ?? '10:00 AM',
      closeTime: map['closeTime'] as String? ?? '08:30 PM',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayOperatingSchedule &&
        other.day == day &&
        other.isOpen == isOpen &&
        other.openTime == openTime &&
        other.closeTime == closeTime;
  }

  @override
  int get hashCode => Object.hash(day, isOpen, openTime, closeTime);
}

/// Domain class representing structured weekly operating hours per day.
@immutable
class OperatingHoursModel {
  const OperatingHoursModel({
    required this.dailySchedules,
  });

  final Map<String, DayOperatingSchedule> dailySchedules;

  static const List<String> allWeekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const OperatingHoursModel defaultSchedule = OperatingHoursModel(
    dailySchedules: {
      'Monday': DayOperatingSchedule(day: 'Monday', isOpen: true, openTime: '08:00 AM', closeTime: '08:00 PM'),
      'Tuesday': DayOperatingSchedule(day: 'Tuesday', isOpen: true, openTime: '08:00 AM', closeTime: '08:00 PM'),
      'Wednesday': DayOperatingSchedule(day: 'Wednesday', isOpen: true, openTime: '08:00 AM', closeTime: '08:00 PM'),
      'Thursday': DayOperatingSchedule(day: 'Thursday', isOpen: true, openTime: '08:00 AM', closeTime: '08:00 PM'),
      'Friday': DayOperatingSchedule(day: 'Friday', isOpen: true, openTime: '08:00 AM', closeTime: '08:00 PM'),
      'Saturday': DayOperatingSchedule(day: 'Saturday', isOpen: true, openTime: '08:00 AM', closeTime: '08:00 PM'),
      'Sunday': DayOperatingSchedule(day: 'Sunday', isOpen: false, openTime: '08:00 AM', closeTime: '08:00 PM'),
    },
  );

  /// Helper to generate human-readable summary
  String get summary {
    final openDays = dailySchedules.entries.where((e) => e.value.isOpen).toList();
    if (openDays.isEmpty) return 'Closed All Days';

    final monSatOpen = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        .every((d) => dailySchedules[d]?.isOpen == true);
    final sunOpen = dailySchedules['Sunday']?.isOpen == true;

    final firstOpen = openDays.first.value;
    if (monSatOpen && !sunOpen) {
      return 'Mon - Sat: ${firstOpen.openTime} - ${firstOpen.closeTime} (Sun Closed)';
    } else if (monSatOpen && sunOpen) {
      return 'Mon - Sun: ${firstOpen.openTime} - ${firstOpen.closeTime} (All Days Open)';
    }

    return '${openDays.length} Days Open';
  }

  /// Calculates whether the studio is currently OPEN or CLOSED right now.
  bool isCurrentlyOpen([DateTime? currentTime]) {
    final now = currentTime ?? DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDay = dayNames[now.weekday - 1];

    final schedule = dailySchedules[currentDay];
    if (schedule == null || !schedule.isOpen) return false;

    final openMinutes = parseTimeToMinutes(schedule.openTime);
    final closeMinutes = parseTimeToMinutes(schedule.closeTime);
    final currentMinutes = now.hour * 60 + now.minute;

    if (openMinutes == null || closeMinutes == null) return true;

    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  static int? parseTimeToMinutes(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.endsWith('PM');
      final isAm = clean.endsWith('AM');
      final parts = clean.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
      if (parts.isEmpty) return null;

      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;

      return hour * 60 + minute;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'dailySchedules': dailySchedules.map((k, v) => MapEntry(k, v.toMap())),
    };
  }

  factory OperatingHoursModel.fromMap(Map<String, dynamic> map) {
    if (map['dailySchedules'] != null && map['dailySchedules'] is Map) {
      final rawMap = Map<String, dynamic>.from(map['dailySchedules'] as Map);
      final schedules = <String, DayOperatingSchedule>{};
      for (final day in allWeekDays) {
        if (rawMap[day] != null && rawMap[day] is Map) {
          schedules[day] = DayOperatingSchedule.fromMap(
            Map<String, dynamic>.from(rawMap[day] as Map),
            day,
          );
        } else {
          schedules[day] = DayOperatingSchedule(
            day: day,
            isOpen: day != 'Sunday',
          );
        }
      }
      return OperatingHoursModel(dailySchedules: schedules);
    }

    // Fallback if legacy map structure
    final openTime = map['openTime'] as String? ?? '10:00 AM';
    final closeTime = map['closeTime'] as String? ?? '08:30 PM';
    final openDaysList = (map['openDays'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    final schedules = <String, DayOperatingSchedule>{};
    for (final day in allWeekDays) {
      final isOpen = openDaysList.contains(day);
      schedules[day] = DayOperatingSchedule(
        day: day,
        isOpen: isOpen,
        openTime: openTime,
        closeTime: closeTime,
      );
    }
    return OperatingHoursModel(dailySchedules: schedules);
  }

  OperatingHoursModel copyWith({
    Map<String, DayOperatingSchedule>? dailySchedules,
  }) {
    return OperatingHoursModel(
      dailySchedules: dailySchedules ?? this.dailySchedules,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OperatingHoursModel && mapEquals(other.dailySchedules, dailySchedules);
  }

  @override
  int get hashCode => Object.hashAll(dailySchedules.entries);
}

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
    this.operatingHours,
    this.description,
    this.logoUrl,
    this.establishedYear,
    required this.isActive,
  });

  final String id;
  final String name;
  final String subtitle;
  final String? phone;
  final String? email;
  final String? address;
  final String? openingHours;
  final OperatingHoursModel? operatingHours;
  final String? description;
  final String? logoUrl;
  final String? establishedYear;
  final bool isActive;

  BoutiqueModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? phone,
    String? email,
    String? address,
    String? openingHours,
    OperatingHoursModel? operatingHours,
    String? description,
    String? logoUrl,
    String? establishedYear,
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
      operatingHours: operatingHours ?? this.operatingHours,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      establishedYear: establishedYear ?? this.establishedYear,
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
        other.operatingHours == operatingHours &&
        other.description == description &&
        other.logoUrl == logoUrl &&
        other.establishedYear == establishedYear &&
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
      operatingHours,
      description,
      logoUrl,
      establishedYear,
      isActive,
    );
  }

  @override
  String toString() {
    return 'BoutiqueModel(id: $id, name: $name, subtitle: $subtitle, phone: $phone, email: $email, address: $address, openingHours: $openingHours, operatingHours: $operatingHours, description: $description, logoUrl: $logoUrl, establishedYear: $establishedYear, isActive: $isActive)';
  }
}
