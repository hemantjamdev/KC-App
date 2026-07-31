import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/network_connectivity_service.dart';

/// Wraps application layout to listen for network state changes.
/// Shows floating toast when offline ("You are offline") or back online ("You are online"),
/// lasting for exactly 3 seconds.
class NetworkListenerWrapper extends StatefulWidget {
  const NetworkListenerWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<NetworkListenerWrapper> createState() =>
      _NetworkListenerWrapperState();
}

class _NetworkListenerWrapperState extends State<NetworkListenerWrapper> {
  StreamSubscription<bool>? _sub;
  bool? _isOnline;

  @override
  void initState() {
    super.initState();
    NetworkConnectivityService.instance.initialize();
    _sub = NetworkConnectivityService.instance.onConnectivityChanged
        .listen((online) {
      if (_isOnline != null && _isOnline != online) {
        _showConnectivityToast(online);
      }
      _isOnline = online;
    });
  }

  void _showConnectivityToast(bool online) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: online ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                online ? 'You are online' : 'You are offline',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
