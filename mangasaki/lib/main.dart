import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'views/login_view.dart';
import 'views/main_view.dart';
import 'widgets/global_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solo inicializar el window_manager en plataformas de escritorio
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    // Inicializar el gestor de ventanas solo en plataformas de escritorio
    await windowManager.ensureInitialized();

    // Configurar propiedades iniciales de la ventana
    WindowOptions windowOptions = const WindowOptions(
      title: 'Mangasaki!',
      size: Size(1280, 720),
      minimumSize: Size(600, 800),
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalState(), // Proveemos GlobalState a la aplicación
      child: const MyApp(),
    ),
  );
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
    //return Scaffold(body: MainView());
  }
}
