import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/colors.dart';

class BirthdayCardScreen extends StatefulWidget {
  const BirthdayCardScreen({super.key});

  @override
  State<BirthdayCardScreen> createState() => _BirthdayCardScreenState();
}

class _BirthdayCardScreenState extends State<BirthdayCardScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..loadFlutterAsset('assets/html/birthday_card.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Birthday Card Studio'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _controller.reload();
            },
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: const Color(0xFF07111F),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFC9A227)),
                    SizedBox(height: 16),
                    Text(
                      'Loading Birthday Card Studio...',
                      style: TextStyle(color: Color(0xFFC9A227), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
