import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/debug/production_devtools/error_logger/error_log_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class ErrorLogTile extends StatelessWidget {
  final ErrorLogModel log;
  final VoidCallback onTap;

  const ErrorLogTile({super.key, required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(log.severity);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.color.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: severityColor.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(
                        _getSeverityIcon(log.severity),
                        size: 14,
                        color: severityColor,
                      ),
                      CustomText(
                        log.severity.label,
                        style: TextStyle(
                          fontSize: context.font.xSmall,
                          color: severityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    log.errorType,
                    style: TextStyle(
                      fontSize: context.font.xSmall,
                      color: context.color.outline,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    ellipsis: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomText(
              log.message,
              style: TextStyle(
                fontSize: context.font.small,
                color: context.color.onSurface,
              ),
              maxLines: 2,
              ellipsis: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: context.color.outline),
                const SizedBox(width: 4),
                CustomText(
                  _formatTime(log.timestamp),
                  style: TextStyle(
                    fontSize: context.font.xSmall,
                    color: context.color.outline,
                  ),
                ),
                if (log.source != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.source_outlined,
                    size: 12,
                    color: context.color.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: CustomText(
                      log.source!,
                      style: TextStyle(
                        fontSize: context.font.xSmall,
                        color: context.color.outline,
                      ),
                      maxLines: 1,
                      ellipsis: true,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
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
