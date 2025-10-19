// Install Prompt Widget
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/pwa_service.dart';

class InstallPromptWidget extends StatefulWidget {
  @override
  _InstallPromptWidgetState createState() => _InstallPromptWidgetState();
}

class _InstallPromptWidgetState extends State<InstallPromptWidget> {
  bool _showPrompt = false;
  bool _isInstalled = false;
  
  @override
  void initState() {
    super.initState();
    _checkInstallStatus();
  }
  
  void _checkInstallStatus() {
    setState(() {
      _isInstalled = PWAService.isInstalled;
      _showPrompt = PWAService.canInstall;
    });
  }
  
  Future<void> _installApp() async {
    if (kIsWeb) {
      // Show install prompt
      await PWAService.showInstallPrompt();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !_showPrompt || _isInstalled) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.install_mobile,
            color: Colors.blue,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'Install Squart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add to your home screen for a better gaming experience',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPrompt = false;
                  });
                },
                child: Text('Not now'),
              ),
              ElevatedButton(
                onPressed: _installApp,
                child: Text('Install'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
