import 'package:elms/core/api/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Debug error tester with overlay button
///
/// This widget shows a floating bug button in debug mode that can be used
/// anywhere in the app to test error scenarios.
///
/// Usage - Initialize once in your app (in main.dart or app.dart):
/// ```dart
/// void main() {
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: DebugErrorTester.wrap(
///         child: YourMainScreen(),
///       ),
///     );
///   }
/// }
/// ```
///
/// Or show manually from anywhere:
/// ```dart
/// DebugErrorTester.show(context);
/// ```
class DebugErrorTester {
  static OverlayEntry? _overlayEntry;
  static bool _isButtonVisible = false;
  static bool _isInitialized = false;

  /// Show the floating debug button
  static void showButton(BuildContext context) {
    if (!kDebugMode) return;
    if (_isButtonVisible || _isInitialized) return;

    _isInitialized = true;

    try {
      _overlayEntry = OverlayEntry(
        builder: (context) => const _DebugFloatingButton(),
      );

      Overlay.of(context).insert(_overlayEntry!);
      _isButtonVisible = true;
    } catch (e) {
      _isInitialized = false;
      // Silently fail - overlay might not be ready yet
    }
  }

  /// Hide the floating debug button
  static void hideButton() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isButtonVisible = false;
    _isInitialized = false;
  }

  /// Show the error test menu
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const DebugErrorMenu(),
    );
  }
}

/// Floating button widget that appears as overlay
class _DebugFloatingButton extends StatefulWidget {
  const _DebugFloatingButton();

  @override
  State<_DebugFloatingButton> createState() => _DebugFloatingButtonState();
}

class _DebugFloatingButtonState extends State<_DebugFloatingButton> {
  double _xPosition = 20;
  double _yPosition = 100;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: _xPosition,
      top: _yPosition,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _xPosition += details.delta.dx;
            _yPosition += details.delta.dy;

            // Keep button within screen bounds
            _xPosition = _xPosition.clamp(0.0, screenWidth - 56);
            _yPosition = _yPosition.clamp(0.0, screenHeight - 56);
          });
        },
        onTap: () => DebugErrorTester.show(context),
        child: Material(
          elevation: 8,
          shape: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TestErrorSimulator.isTestErrorEnabled
                  ? Colors.orange
                  : Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bug_report, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet menu for selecting error types
class DebugErrorMenu extends StatelessWidget {
  const DebugErrorMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isTestModeActive = TestErrorSimulator.isTestErrorEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Test Error Simulator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isTestModeActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildErrorTile(
                  context,
                  icon: Icons.wifi_off,
                  title: 'No Internet',
                  subtitle: 'Shows no internet widget',
                  color: Colors.orange,
                  onTap: () {
                    TestErrorSimulator.testNoInternet();
                    Navigator.pop(context);
                    _showSnackbar(context, 'No Internet error enabled');
                  },
                ),
                _buildErrorTile(
                  context,
                  icon: Icons.lock,
                  title: '401 Unauthorized',
                  subtitle: 'Triggers auto logout',
                  color: Colors.red,
                  onTap: () {
                    TestErrorSimulator.testUnauthorized();
                    Navigator.pop(context);
                    // Will auto logout and navigate to login
                  },
                ),
                _buildErrorTile(
                  context,
                  icon: Icons.error_outline,
                  title: '500 Server Error',
                  subtitle: 'Shows server error message',
                  color: Colors.red[700]!,
                  onTap: () {
                    TestErrorSimulator.testServerError(
                      message: 'Test server error from debug menu',
                    );
                    Navigator.pop(context);
                    _showSnackbar(context, 'Server error enabled');
                  },
                ),
                _buildErrorTile(
                  context,
                  icon: Icons.cloud_off,
                  title: '503 Service Unavailable',
                  subtitle: 'Server maintenance mode',
                  color: Colors.grey,
                  onTap: () {
                    TestErrorSimulator.testServerUnavailable();
                    Navigator.pop(context);
                    _showSnackbar(context, 'Service unavailable error enabled');
                  },
                ),
                _buildErrorTile(
                  context,
                  icon: Icons.warning,
                  title: '422 Validation Error',
                  subtitle: 'Form validation failed',
                  color: Colors.amber,
                  onTap: () {
                    TestErrorSimulator.testValidationError(
                      message: 'Test validation error',
                    );
                    Navigator.pop(context);
                    _showSnackbar(context, 'Validation error enabled');
                  },
                ),
                _buildErrorTile(
                  context,
                  icon: Icons.access_time,
                  title: 'Timeout Error',
                  subtitle: 'Connection timeout',
                  color: Colors.blue,
                  onTap: () {
                    TestErrorSimulator.testTimeout();
                    Navigator.pop(context);
                    _showSnackbar(context, 'Timeout error enabled');
                  },
                ),
                _buildErrorTile(
                  context,
                  icon: Icons.system_update_alt,
                  title: '410 Force Update',
                  subtitle: 'App update required',
                  color: Colors.purple,
                  onTap: () {
                    TestErrorSimulator.testForceUpdate();
                    Navigator.pop(context);
                    _showSnackbar(context, 'Force update error enabled');
                  },
                ),
                _buildErrorTile(
                  context,
                  icon: Icons.format_textdirection_r_to_l,
                  title: 'Toggle RTL Direction',
                  subtitle: 'Simulate Right-to-Left layout',
                  color: TestErrorSimulator.isRtlSimulationEnabled
                      ? Colors.green
                      : Colors.purple,
                  onTap: () {
                    TestErrorSimulator.toggleRtlSimulation();
                    // Force rebuild of the whole app
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Get.forceAppUpdate();
                    });
                    Navigator.pop(context);
                    _showSnackbar(
                      context,
                      TestErrorSimulator.isRtlSimulationEnabled
                          ? 'RTL Mode Enabled'
                          : 'RTL Mode Disabled',
                    );
                  },
                ),
                const Divider(height: 32),
                _buildErrorTile(
                  context,
                  icon: Icons.check_circle,
                  title: 'Disable Test Errors',
                  subtitle: 'Return to normal API calls',
                  color: Colors.green,
                  onTap: () {
                    TestErrorSimulator.disableTestError();
                    Navigator.pop(context);
                    _showSnackbar(
                      context,
                      'Test errors disabled',
                      isSuccess: true,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
