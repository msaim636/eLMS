import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_text.dart';
import 'package:elms/core/debug/production_devtools/api_logger/api_logger_service.dart';
import 'package:elms/core/debug/production_devtools/error_logger/error_logger_service.dart';
import 'package:elms/core/debug/production_devtools/screens/api_logs_screen.dart';
import 'package:elms/core/debug/production_devtools/screens/error_logs_screen.dart';
import 'package:elms/core/debug/production_devtools/widgets/feature_card.dart';
import 'package:elms/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class DevtoolsScreen extends StatefulWidget {
  const DevtoolsScreen({super.key});

  @override
  State<DevtoolsScreen> createState() => _DevtoolsScreenState();
}

class _DevtoolsScreenState extends State<DevtoolsScreen> {
  final ApiLoggerService _apiLoggerService = ApiLoggerService.instance;
  final ErrorLoggerService _errorLoggerService = ErrorLoggerService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await Future.wait([_apiLoggerService.init(), _errorLoggerService.init()]);
    setState(() => _isLoading = false);
  }

  void _onTapApiLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ApiLogsScreen()),
    );
  }

  void _onTapErrorLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ErrorLogsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Diagnostic Tools',
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewSection(),
                  const SizedBox(height: 24),
                  _buildFeaturesGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    final totalApiLogs = _apiLoggerService.totalCount;
    final totalErrors = _errorLoggerService.totalCount;
    final criticalErrors =
        _errorLoggerService.errorCount + _errorLoggerService.fatalCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.color.primary.withValues(alpha: 0.1),
            context.color.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.color.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_outlined,
                color: context.color.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              CustomText(
                'Overview',
                style: TextStyle(
                  fontSize: context.font.medium,
                  fontWeight: FontWeight.bold,
                  color: context.color.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  icon: Icons.api_outlined,
                  label: 'API Calls',
                  value: '$totalApiLogs',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  icon: Icons.bug_report_outlined,
                  label: 'Total Logs',
                  value: '$totalErrors',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  icon: Icons.error_outline,
                  label: 'Critical',
                  value: '$criticalErrors',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        CustomText(
          value,
          style: TextStyle(
            fontSize: context.font.xxLarge,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        CustomText(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: context.color.outline),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Features',
          style: TextStyle(
            fontSize: context.font.medium,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            FeatureCard(
              title: 'API Logs',
              description: 'Monitor network requests and responses',
              icon: Icons.api_outlined,
              color: Colors.blue,
              badge: _apiLoggerService.totalCount > 0
                  ? '${_apiLoggerService.totalCount}'
                  : null,
              onTap: _onTapApiLogs,
            ),
            FeatureCard(
              title: 'Error Logs',
              description: 'Track runtime errors and exceptions',
              icon: Icons.bug_report_outlined,
              color: Colors.red,
              badge: _errorLoggerService.totalCount > 0
                  ? '${_errorLoggerService.totalCount}'
                  : null,
              onTap: _onTapErrorLogs,
            ),
            FeatureCard(
              title: 'Performance',
              description: 'Coming soon',
              icon: Icons.speed_outlined,
              color: Colors.purple.withValues(alpha: 0.5),
              onTap: () => _showComingSoon(),
            ),
            FeatureCard(
              title: 'Storage',
              description: 'Coming soon',
              icon: Icons.storage_outlined,
              color: Colors.teal.withValues(alpha: 0.5),
              onTap: () => _showComingSoon(),
            ),
          ],
        ),
      ],
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
