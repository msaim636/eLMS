import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/debug/production_devtools/error_logger/error_log_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ErrorLogDetailSheet extends StatelessWidget {
  final ErrorLogModel log;

  const ErrorLogDetailSheet({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(context),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    title: 'Error Type',
                    content: log.errorType,
                    canCopy: true,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    title: 'Message',
                    content: log.message,
                    canCopy: true,
                  ),
                  if (log.source != null) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: 'Source',
                      content: log.source!,
                      canCopy: true,
                    ),
                  ],
                  if (log.stackTrace != null) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: 'Stack Trace',
                      content: log.stackTrace!,
                      canCopy: true,
                      isMonospace: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final severityColor = _getSeverityColor(log.severity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.surface,
        border: Border(
          bottom: BorderSide(
            color: context.color.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(
                  _getSeverityIcon(log.severity),
                  size: 18,
                  color: severityColor,
                ),
                CustomText(
                  log.severity.label,
                  style: TextStyle(
                    fontSize: context.font.small,
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.color.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, 'Timestamp', _formatDateTime(log.timestamp)),
          _buildInfoRow(context, 'Severity', log.severity.label),
          if (log.source != null) _buildInfoRow(context, 'Source', log.source!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: context.color.outline),
          ),
          Flexible(
            child: CustomText(
              value,
              style: TextStyle(
                fontSize: context.font.small,
                color: context.color.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              ellipsis: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    bool canCopy = false,
    bool isMonospace = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              title,
              style: TextStyle(
                fontSize: context.font.small,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (canCopy)
              IconButton(
                onPressed: () => _copyToClipboard(context, content),
                icon: const Icon(Icons.copy, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.color.textSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.color.outline.withValues(alpha: 0.2),
            ),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              fontSize: context.font.xSmall,
              fontFamily: isMonospace ? 'monospace' : null,
              color: context.color.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(BuildContext context, String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    return switch (severity) {
      ErrorSeverity.info => Colors.blue,
      ErrorSeverity.warning => Colors.orange,
      ErrorSeverity.error => Colors.red,
      ErrorSeverity.fatal => Colors.purple,
    };
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    return switch (severity) {
      ErrorSeverity.info => Icons.info_outline,
      ErrorSeverity.warning => Icons.warning_amber_rounded,
      ErrorSeverity.error => Icons.error_outline,
      ErrorSeverity.fatal => Icons.dangerous_outlined,
    };
  }
}
