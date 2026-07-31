import 'package:flutter/material.dart';
import 'app_empty_state.dart';

/// Legacy alias delegating to AppEmptyState for component consolidation.
class CustomerEmptyState extends StatelessWidget {
  const CustomerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon,
      title: title,
      message: subtitle ?? '',
      actionLabel: actionLabel,
      onAction: action,
    );
  }
}
