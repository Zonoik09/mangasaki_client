import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'connection/NotificationRepository.dart';
import 'connection/app_data.dart';
import 'connection/friendManager.dart';
import 'connection/userStorage.dart';
import 'views/login_view.dart';
import 'views/main_view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Importar el paquete de notificaciones

// Aquí agregamos el FlutterLocalNotificationsPlugin global
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el entorno de notificaciones locales
  if (Platform.isAndroid || Platform.isIOS) {
    await NotificationRepository.notificationPlugin();
  } else if (Platform.isWindows) {
    await NotificationRepository.initWindowsNotifications();
  }

  // Código existente para la configuración de la ventana (solo en escritorio)
  if (Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      title: 'Mangasaki!',
      size: Size(1280, 800),
      minimumSize: Size(600, 800),
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppData()),
        ChangeNotifierProvider(create: (_) => FriendManager()),
      ],
      child: const MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // Asignar el contexto global
        Messaging.openContext = context;

        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoginScreen());
    // Puedes descomentar la siguiente línea para mostrar la vista principal:
    // return Scaffold(body: MainView());
  }
}
