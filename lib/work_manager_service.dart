import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:untitled3/local_service.dart';

/// **Top-level callback entry-point** for background execution.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // Initialize Flutter bindings for the background isolate
      WidgetsFlutterBinding.ensureInitialized();

      // Show the notification
      await LocalService.showBasicNotification();
      return true;
    } catch (e) {
      print('Error in callbackDispatcher: $e');
      return false;
    }
  });
}

class WorkManagerService {
  /// Initialize Workmanager with our top-level dispatcher
  Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  /// Register a one-off task
  Future<void> registerTask() async {
    await Workmanager().registerOneOffTask(
      "notificationTask",
      "showNotification",
      initialDelay: Duration(seconds: 1), // Optional delay
    );
  }

  /// Cancel all tasks
  Future<void> cancelTasks() async {
    await Workmanager().cancelAll();
  }
}