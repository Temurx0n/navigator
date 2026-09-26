import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/map/bloc/map_bloc.dart';
import 'features/map/bloc/map_event.dart';
import 'features/map/bloc/map_state.dart';
import 'features/map_page.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationService();

  await notificationService.initialize();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.subscribeToTopic(
    'navigator',
  );

  FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
      debugPrint(
        'FCM message: ${message.notification?.title}',
      );

      debugPrint(
        'FCM body: ${message.notification?.body}',
      );
    },
  );

  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    );

    return true;
  };

  runApp(
    MyApp(
      notificationService: notificationService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(
        notificationService: notificationService,
      )..add(MapStarted()),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const MapPage(),
          );
        },
      ),
    );
  }
}