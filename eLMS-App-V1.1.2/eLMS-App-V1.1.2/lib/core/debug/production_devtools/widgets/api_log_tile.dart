import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/debug/production_devtools/api_logger/api_log_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class ApiLogTile extends StatelessWidget {
  final ApiLogModel log;
  final VoidCallback onTap;

  const ApiLogTile({super.key, required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final methodColor = _getMethodColor(log.method);
    final statusColor = log.isSuccess ? Colors.green : context.color.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.color.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: log.isSuccess
                ? context.color.outline.withValues(alpha: 0.3)
                : context.color.error.withValues(alpha: 0.5),
          ),
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
                    color: methodColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CustomText(
                    log.method,
                    style: TextStyle(
                      fontSize: context.font.xSmall,
                      color: methodColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (log.statusCode != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomText(
                      '${log.statusCode}',
                      style: TextStyle(
                        fontSize: context.font.xSmall,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                if (log.durationMs != null)
                  CustomText(
                    '${log.durationMs}ms',
                    style: TextStyle(
                      fontSize: context.font.xSmall,
                      color: _getDurationColor(log.durationMs!),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            CustomText(
              _getShortEndpoint(log.endpoint),
              style: TextStyle(
                fontSize: context.font.small,
                color: context.color.onSurface,
              ),
              maxLines: 1,
              ellipsis: true,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: context.color.outline),
                const SizedBox(width: 4),
                CustomText(
                  _formatTime(log.requestTime),
                  style: TextStyle(
                    fontSize: context.font.xSmall,
                    color: context.color.outline,
                  ),
                ),
                if (log.errorMessage != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomText(
                      log.errorMessage!,
                      style: TextStyle(
                        fontSize: context.font.xSmall,
                        color: context.color.error,
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

  String _getShortEndpoint(String endpoint) {
    try {
      final uri = Uri.parse(endpoint);
      return uri.path + (uri.query.isNotEmpty ? '?...' : '');
    } catch (_) {
      return endpoint;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  Color _getMethodColor(String method) {
    return switch (method) {
      'GET' => Colors.blue,
      'POST' => Colors.green,
      'PUT' => Colors.orange,
      'PATCH' => Colors.purple,
      'DELETE' => Colors.red,
      _ => Colors.grey,
    };
  }

  Color _getDurationColor(int durationMs) {
    if (durationMs < 200) return Colors.green;
    if (durationMs < 500) return Colors.orange;
    return Colors.red;
  }
}
