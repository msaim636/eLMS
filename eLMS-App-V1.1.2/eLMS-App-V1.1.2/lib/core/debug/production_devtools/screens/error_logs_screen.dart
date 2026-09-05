import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/debug/production_devtools/error_logger/error_log_model.dart';
import 'package:elms/core/debug/production_devtools/error_logger/error_logger_service.dart';
import 'package:elms/core/debug/production_devtools/widgets/error_log_detail_sheet.dart';
import 'package:elms/core/debug/production_devtools/widgets/error_log_tile.dart';
import 'package:elms/core/debug/production_devtools/widgets/stats_card.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:elms/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ErrorLogsScreen extends StatefulWidget {
  const ErrorLogsScreen({super.key});

  @override
  State<ErrorLogsScreen> createState() => _ErrorLogsScreenState();
}

class _ErrorLogsScreenState extends State<ErrorLogsScreen> {
  final ErrorLoggerService _loggerService = ErrorLoggerService.instance;
  bool _isLoading = true;
  ErrorSeverity? _severityFilter;
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

  void _onTapLog(ErrorLogModel log) {
    UiUtils.showCustomBottomSheet(
      context,
      child: ErrorLogDetailSheet(log: log),
    );
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
          'Are you sure you want to clear all error logs?',
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

  void _onTapFilterSeverity(ErrorSeverity? severity) {
    setState(() {
      _severityFilter = _severityFilter == severity ? null : severity;
    });
  }

  void _onTapAddTestLog() {
    _loggerService.logError(
      error: Exception('Test error at ${DateTime.now()}'),
      stackTrace: StackTrace.current,
      source: 'TestButton',
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test log added! Check console for save confirmation.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<ErrorLogModel> get _filteredLogs {
    return _loggerService.getFilteredLogs(
      severityFilter: _severityFilter,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Error Logs',
        actions: [
          // Test button to manually add a log
          IconButton(
            onPressed: _onTapAddTestLog,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Test Log',
          ),
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
              title: 'Errors',
              value: '${_loggerService.errorCount}',
              color: Colors.red,
            ),
          ),
          Expanded(
            child: StatsCard(
              title: 'Warnings',
              value: '${_loggerService.warningCount}',
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: StatsCard(
              title: 'Fatal',
              value: '${_loggerService.fatalCount}',
              color: Colors.purple,
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
              hintText: 'Search errors...',
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
                _buildFilterChip(ErrorSeverity.info),
                _buildFilterChip(ErrorSeverity.warning),
                _buildFilterChip(ErrorSeverity.error),
                _buildFilterChip(ErrorSeverity.fatal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ErrorSeverity severity) {
    final isSelected = _severityFilter == severity;
    final color = _getSeverityColor(severity);

    return FilterChip(
      label: CustomText(
        severity.label,
        style: TextStyle(
          fontSize: context.font.xSmall,
          color: isSelected ? Colors.white : context.color.onSurface,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => _onTapFilterSeverity(severity),
      selectedColor: color,
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
            Icon(
              Icons.bug_report_outlined,
              size: 64,
              color: context.color.outline,
            ),
            const SizedBox(height: 16),
            CustomText(
              'No error logs yet',
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
        return ErrorLogTile(log: log, onTap: () => _onTapLog(log));
      },
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
}
