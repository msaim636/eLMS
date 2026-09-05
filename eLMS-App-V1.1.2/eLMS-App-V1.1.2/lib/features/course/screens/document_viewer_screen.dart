import 'package:elms/common/widgets/custom_app_bar.dart';
import 'package:elms/common/widgets/custom_error_widget.dart';
import 'package:elms/core/constants/app_labels.dart';
import 'package:elms/core/routes/route_params.dart';
import 'package:elms/utils/screen_protection.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String documentUrl;
  final String documentTitle;

  const DocumentViewerScreen({
    super.key,
    required this.documentUrl,
    required this.documentTitle,
  });

  static Widget route([RouteSettings? settings]) {
    final DocumentViewerArguments? arguments =
        (settings?.arguments ?? Get.arguments) as DocumentViewerArguments?;
    if (arguments == null) {
      throw Exception('DocumentViewerScreen requires DocumentViewerArguments');
    }

    return DocumentViewerScreen(
      documentUrl: arguments.documentUrl,
      documentTitle: arguments.documentTitle,
    );
  }

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen>
    with ScreenProtection {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Use Google Docs Viewer to display documents in WebView
    final String viewerUrl =
        'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.documentUrl)}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.documentTitle, showBackButton: true),
      body: _hasError
          ? CustomErrorWidget<String>(
              error: _errorMessage.isNotEmpty
                  ? _errorMessage
                  : AppLabels.failedToLoadDocument.tr,
              onRetry: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _initializeController();
              },
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
