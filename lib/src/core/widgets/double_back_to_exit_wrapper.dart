import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Wraps root/shell screens to prevent immediate exit on back press.
/// First back press shows a 3-second toast: "Press back again to exit".
/// Second back press within 3 seconds exits the application.
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
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 3)) {
          _lastBackPressTime = now;
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: const Color(0xFF1F2937),
              duration: const Duration(seconds: 3),
              content: Row(
                children: [
                  const Icon(
                    Icons.exit_to_app_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Press back again to exit',
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
        } else {
          await SystemNavigator.pop();
        }
      },
      child: widget.child,
    );
  }
}
