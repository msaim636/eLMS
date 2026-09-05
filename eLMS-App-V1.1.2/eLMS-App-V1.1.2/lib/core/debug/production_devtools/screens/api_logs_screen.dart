import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/debug/production_devtools/api_logger/api_log_model.dart';
import 'package:elms/core/debug/production_devtools/api_logger/api_logger_service.dart';
import 'package:elms/core/debug/production_devtools/widgets/api_log_detail_sheet.dart';
import 'package:elms/core/debug/production_devtools/widgets/api_log_tile.dart';
import 'package:elms/core/debug/production_devtools/widgets/stats_card.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ApiLogsScreen extends StatefulWidget {
  const ApiLogsScreen({super.key});

  @override
  State<ApiLogsScreen> createState() => _ApiLogsScreenState();
}

class _ApiLogsScreenState extends State<ApiLogsScreen> {
  final ApiLoggerService _loggerService = ApiLoggerService.instance;
  bool _isLoading = true;
  String? _methodFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initLogs();
  }

  Future<void> _initLogs() async {
    await _loggerService.init();
    setState(() => _isLoading = false);
  }

  void _onTapLog(ApiLogModel log) {
    UiUtils.showCustomBottomSheet(context, child: ApiLogDetailSheet(log: log));
  }

  void _onTapClearLogs() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: CustomText(
          'Clear Logs',
          style: Theme.of(ctx).textTheme.titleMedium!,
        ),
        content: CustomText(
          'Are you sure you want to clear all API logs?',
          style: Theme.of(ctx).textTheme.bodyMedium!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: CustomText(
              'Cancel',
              style: Theme.of(ctx).textTheme.bodyMedium!,
            ),
          ),
          TextButton(
            onPressed: () {
              _loggerService.clearLogs();
              Navigator.pop(ctx);
              setState(() {});
            },
            child: CustomText(
              'Clear',
              style: Theme.of(ctx).textTheme.bodyMedium!.copyWith(
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTapFilterMethod(String? method) {
    setState(() {
      _methodFilter = _methodFilter == method ? null : method;
    });
  }

  List<ApiLogModel> get _filteredLogs {
    return _loggerService.getFilteredLogs(
      methodFilter: _methodFilter,
      endpointFilter: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'API Logs',
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _onTapClearLogs,
            icon: Icon(Icons.delete_outline, color: context.color.error),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsSection(),
                _buildSearchAndFilter(),
                Expanded(child: _buildLogsList()),
              ],
            ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: StatsCard(
              title: 'Total',
              value: '${_loggerService.totalCount}',
              color: context.color.primary,
            ),
          ),
          Expanded(
            child: StatsCard(
              title: 'Success',
              value: '${_loggerService.successCount}',
              color: Colors.green,
            ),
          ),
          Expanded(
            child: StatsCard(
              title: 'Failed',
              value: '${_loggerService.failCount}',
              color: context.color.error,
            ),
          ),
          Expanded(
            child: StatsCard(
              title: 'Avg Time',
              value:
                  '${_loggerService.averageResponseTime.toStringAsFixed(0)}ms',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 12,
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search endpoint...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                _buildFilterChip('GET'),
                _buildFilterChip('POST'),
                _buildFilterChip('PUT'),
                _buildFilterChip('PATCH'),
                _buildFilterChip('DELETE'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String method) {
    final isSelected = _methodFilter == method;
    return FilterChip(
      label: CustomText(
        method,
        style: TextStyle(
          fontSize: context.font.xSmall,
          color: isSelected ? Colors.white : context.color.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => _onTapFilterMethod(method),
      selectedColor: _getMethodColor(method),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildLogsList() {
    final logs = _filteredLogs;

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.api_outlined, size: 64, color: context.color.outline),
            const SizedBox(height: 16),
            CustomText(
              'No API logs yet',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: context.color.outline),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final log = logs[index];
        return ApiLogTile(log: log, onTap: () => _onTapLog(log));
      },
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
