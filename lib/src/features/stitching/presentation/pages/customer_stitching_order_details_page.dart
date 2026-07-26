import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kc_app/src/features/boutique/presentation/controllers/boutique_selection_controller.dart';
import 'package:kc_app/src/features/stitching/domain/models/stitching_order_model.dart';
import 'package:kc_app/src/features/stitching/presentation/controllers/stitching_order_controller.dart';
import 'package:kc_app/src/features/stitching/presentation/widgets/stitching_order_timeline.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';

/// Customer Stitching Order Details Page — progress overview, items list, measurements, and customer timeline.
class CustomerStitchingOrderDetailsPage extends StatefulWidget {
  const CustomerStitchingOrderDetailsPage({super.key, required this.order});
  final StitchingOrderModel order;

  @override
  State<CustomerStitchingOrderDetailsPage> createState() =>
      _CustomerStitchingOrderDetailsPageState();
}

class _CustomerStitchingOrderDetailsPageState
    extends State<CustomerStitchingOrderDetailsPage> {
  late StitchingOrderModel _order;
  late StitchingOrderController _controller;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = BoutiqueSelectionScope.of(context);
    _controller = StitchingOrderController(
      boutiqueId: scope.selectedBoutique?.id ?? 'boutique_01',
      branchId: scope.selectedBranch?.id,
    );
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    final fresh = _controller.getOrderById(_order.id);
    if (fresh != null && mounted) {
      setState(() => _order = fresh);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'To be confirmed';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scope = BoutiqueSelectionScope.of(context);
    final boutique = scope.selectedBoutique;
    final branch = scope.selectedBranch;
    final history = _controller.getHistoryForOrder(_order.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _order.orderNumber,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Banner Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _order.status.customerLabel,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: AppRadius.borderPill,
                          child: LinearProgressIndicator(
                            value: _order.status.progressFraction,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Expected Ready Date',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _formatDate(_order.expectedReadyAt),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Boutique Location Context
                  _infoCard('Boutique & Location', [
                    _infoRow('Boutique', boutique?.name ?? 'Kapada Creation'),
                    _infoRow('Branch', branch?.name ?? 'Main Branch'),
                  ]),

                  const SizedBox(height: AppSpacing.md),

                  // Design References List
                  _infoCard(
                    'Items in Order (${_order.designReferences.length})',
                    _order.designReferences.map((d) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                '${d.designName} (Qty: ${d.quantity})',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Measurement Summary
                  if (_order.measurementSummary != null &&
                      !_order.measurementSummary!.isEmpty) ...[
                    _infoCard('Recorded Measurements', [
                      if (_order.measurementSummary!.chest != null)
                        _infoRow(
                          'Chest',
                          '${_order.measurementSummary!.chest} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.waist != null)
                        _infoRow(
                          'Waist',
                          '${_order.measurementSummary!.waist} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.hip != null)
                        _infoRow(
                          'Hip',
                          '${_order.measurementSummary!.hip} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.shoulder != null)
                        _infoRow(
                          'Shoulder',
                          '${_order.measurementSummary!.shoulder} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.sleeveLength != null)
                        _infoRow(
                          'Sleeve Length',
                          '${_order.measurementSummary!.sleeveLength} ${_order.measurementSummary!.unit}',
                        ),
                      if (_order.measurementSummary!.garmentLength != null)
                        _infoRow(
                          'Garment Length',
                          '${_order.measurementSummary!.garmentLength} ${_order.measurementSummary!.unit}',
                        ),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Timeline Progress History
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Timeline Progress',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        StitchingOrderTimeline(
                          history: history,
                          isCustomerView: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
