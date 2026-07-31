import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_toast.dart';

/// Wraps root/shell screens to prevent immediate exit on back press.
/// - Debounces rapid OS back gesture callbacks (< 350ms).
/// - Shows warning toast on 1st back press on root/shell tabs.
/// - Exits app on 2nd intentional back tap within 2.0s window.
class DoubleBackToExitWrapper extends StatefulWidget {
  const DoubleBackToExitWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<DoubleBackToExitWrapper> createState() =>
      _DoubleBackToExitWrapperState();
}

class _DoubleBackToExitWrapperState extends State<DoubleBackToExitWrapper> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // If Navigator can pop a pushed sub-route, pop that sub-route normally
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }

        // On Root / Shell page: handle double back to exit
        final now = DateTime.now();

        if (_lastBackPressTime != null) {
          final timeDiff = now.difference(_lastBackPressTime!).inMilliseconds;

          // Ignore rapid duplicate OS gesture callbacks (< 350ms)
          if (timeDiff < 350) {
            return;
          }

          // Real 2nd tap within 2000ms (2 seconds): exit the app!
          if (timeDiff <= 2000) {
            await SystemNavigator.pop();
            return;
          }
        }

        // 1st tap (or > 2000ms delay since previous tap): record timestamp & show warning toast
        _lastBackPressTime = now;

        if (!mounted) return;
        AppToast.show(
          context,
          'Press again to exit the app',
          type: ToastType.warning,
        );
      },
      child: widget.child,
    );
  }
}
