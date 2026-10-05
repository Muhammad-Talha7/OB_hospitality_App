import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_button.dart';

class ComplaintDialog extends StatefulWidget {
  final String orderId;

  const ComplaintDialog({
    super.key,
    required this.orderId,
  });

  static Future<void> show(BuildContext context, {required String orderId}) {
    return showDialog(
      context: context,
      builder: (ctx) => ComplaintDialog(orderId: orderId),
    );
  }

  @override
  State<ComplaintDialog> createState() => _ComplaintDialogState();
}

class _ComplaintDialogState extends State<ComplaintDialog> {
  String _selectedReason = 'Missing items in order';
  final _descriptionController = TextEditingController();
  bool _isSubmitted = false;
  bool _isLoading = false;

  final List<String> _reasons = [
    'Missing items in order',
    'Food arrived cold or damaged',
    'Incorrect items delivered',
    'Excessive delivery delay',
    'Quality did not meet expectations',
    'Other issue',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue briefly.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final orderProvider = context.read<OrderProvider>();
    await orderProvider.submitComplaint(
      orderId: widget.orderId,
      reason: _selectedReason,
      description: _descriptionController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.all(16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.report_problem_outlined, color: AppColors.terracotta, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report an Issue', style: AppTypography.displaySmall.copyWith(fontSize: 20)),
                Text('Order #${widget.orderId}', style: AppTypography.labelMedium.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
      content: _isSubmitted
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline, color: AppColors.forest, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We\'ve notified the restaurant',
                    style: AppTypography.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The general manager and kitchen staff have received your report and will reach out if further details are needed.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason for reporting', style: AppTypography.labelMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: _reasons.map((r) {
                    return DropdownMenuItem(value: r, child: Text(r, style: AppTypography.bodyMedium));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedReason = val);
                  },
                ),
                const SizedBox(height: 16),
                Text('Description & details', style: AppTypography.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Please share what went wrong with this order...',
                    hintStyle: AppTypography.bodySmall,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
      actions: _isSubmitted
          ? [
              AppButton(
                label: 'CLOSE',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit Report'),
              ),
            ],
    );
  }
}
