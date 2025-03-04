import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solo inicializar el window_manager en plataformas de escritorio
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    // Inicializar el gestor de ventanas solo en plataformas de escritorio
    await windowManager.ensureInitialized();

    // Configurar propiedades iniciales de la ventana
    WindowOptions windowOptions = const WindowOptions(
      title: 'ImagIA',
      size: Size(600, 800),
      minimumSize: Size(600, 800),
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
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
  }
}
