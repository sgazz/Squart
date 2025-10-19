// PWA Status Widget
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/pwa_service.dart';

class PWAStatusWidget extends StatefulWidget {
  @override
  _PWAStatusWidgetState createState() => _PWAStatusWidgetState();
}

class _PWAStatusWidgetState extends State<PWAStatusWidget> {
  bool _isOnline = true;
  bool _isInstalled = false;
  
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }
  
  void _checkStatus() {
    setState(() {
      _isOnline = PWAService.isOnline;
      _isInstalled = PWAService.isInstalled;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isOnline ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: _isOnline ? Colors.green : Colors.red,
          ),
          SizedBox(width: 4),
          Text(
            _isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: _isOnline ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_isInstalled) ...[
            SizedBox(width: 8),
            Icon(
              Icons.phone_android,
              size: 16,
              color: Colors.blue,
            ),
          ],
        ],
      ),
    );
  }
}
