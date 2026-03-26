import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Generic handler for any permission.
  /// Returns true if granted, false otherwise.
  static Future<bool> handlePermission({
    required BuildContext context,
    required Permission permission,
    required String title,
    required String message,
  }) async {
    final status = await permission.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context, title, message);
      }
      return false;
    }

    // Request it
    final result = await permission.request();
    
    if (result.isGranted) return true;

    if (result.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context, title, message);
      }
    } else if (result.isDenied) {
       if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title permission denied.")),
        );
      }
    }

    return result.isGranted;
  }

  static void _showSettingsDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text("$message\n\nPlease enable it in system settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D40),
              foregroundColor: Colors.white,
            ),
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
