import 'dart:convert';

import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/debug/production_devtools/api_logger/api_log_model.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApiLogDetailSheet extends StatelessWidget {
  final ApiLogModel log;

  const ApiLogDetailSheet({super.key, required this.log});

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
                    title: 'Endpoint',
                    content: log.endpoint,
                    canCopy: true,
                  ),
                  // if (log.requestHeaders != null) ...[
                  //   const SizedBox(height: 16),
                  //   _buildSection(
                  //     context,
                  //     title: 'Request Headers',
                  //     content: _formatJson(log.requestHeaders),
                  //     canCopy: true,
                  //   ),
                  // ],
                  if (log.requestBody != null) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: 'Request Body',
                      content: _formatJson(log.requestBody),
                      canCopy: true,
                    ),
                  ],
                  if (log.responseBody != null) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: 'Response Body',
                      content: _formatJson(log.responseBody),
                      canCopy: true,
                    ),
                  ],
                  if (log.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: 'Error',
                      content: log.errorMessage!,
                      isError: true,
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
    final methodColor = _getMethodColor(log.method);
    final statusColor = log.isSuccess ? Colors.green : context.color.error;

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
              color: methodColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomText(
              log.method,
              style: TextStyle(
                fontSize: context.font.small,
                color: methodColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (log.statusCode != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomText(
                '${log.statusCode}',
                style: TextStyle(
                  fontSize: context.font.small,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
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
          _buildInfoRow(
            context,
            'Request Time',
            _formatDateTime(log.requestTime),
          ),
          if (log.responseTime != null)
            _buildInfoRow(
              context,
              'Response Time',
              _formatDateTime(log.responseTime!),
            ),
          if (log.durationMs != null)
            _buildInfoRow(context, 'Duration', '${log.durationMs}ms'),
          _buildInfoRow(
            context,
            'Status',
            log.isSuccess ? 'Success' : 'Failed',
            valueColor: log.isSuccess ? Colors.green : context.color.error,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
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
          CustomText(
            value,
            style: TextStyle(
              fontSize: context.font.small,
              color: valueColor ?? context.color.onSurface,
              fontWeight: FontWeight.w500,
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
    bool isError = false,
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
                color: isError ? context.color.error : null,
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
            color: isError
                ? context.color.error.withValues(alpha: 0.1)
                : context.color.textSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isError
                  ? context.color.error.withValues(alpha: 0.3)
                  : context.color.outline.withValues(alpha: 0.2),
            ),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              fontSize: context.font.xSmall,
              fontFamily: 'monospace',
              color: isError ? context.color.error : context.color.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _formatJson(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
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
}
