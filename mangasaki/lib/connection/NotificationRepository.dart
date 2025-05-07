import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


// Instanciamos el plugin de notificaciones globalmente
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class Messaging {
  static late BuildContext openContext; // Se asigna desde main()
}

class NotificationRepository {

  static final WindowsNotification _winNotifyPlugin = WindowsNotification(
    applicationId: r"{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}\WindowsPowerShell\v1.0\powershell.exe",
  );

  static Future<void> initWindowsNotifications() async {
    _winNotifyPlugin.initNotificationCallBack((s) {
      print(s.argrument);
      print(s.userInput);
      print(s.eventType);
    });
  }

  static Future<String> getImageBytes(String url) async {
    final supportDir = await getApplicationSupportDirectory();
    final response = await http.get(Uri.parse(url));
    final file = File("${supportDir.path}/${DateTime.now().millisecondsSinceEpoch}.png");
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  static Future<void> showMessageStyleNotification() async {
    const String url =
        "https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Sample_User_Icon.png/240px-Sample_User_Icon.png";

    final imagePath = await getImageBytes(url);

    NotificationMessage message = NotificationMessage.fromPluginTemplate(
      "Nuevo mensaje",
      "Juan te ha enviado un mensaje",
      "Hola, ¿cómo estás?",
      image: imagePath,
      launch: "https://example.com",
    );

    _winNotifyPlugin.showNotificationPluginTemplate(message);
  }

  static void showTextOnlyNotification() {
    NotificationMessage message = NotificationMessage.fromPluginTemplate(
      "Recordatorio",
      "Tienes una cita hoy",
      "Recuerda que tienes una reunión a las 4 PM",
      launch: "https://example.com",
    );

    _winNotifyPlugin.showNotificationPluginTemplate(message);
  }

  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'channel_id', // ID único
    'Channel Title',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> notificationPlugin() async {
    // Crear canal (solo Android)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (Platform.isIOS) {
      final bool? permissionGranted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (permissionGranted != null && permissionGranted) {
        print("Permissions granted");
      } else {
        print("Permissions denied");
      }
    }


    // Configuración Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        return showDialog(
          context: Messaging.openContext,
          builder: (_) => CupertinoAlertDialog(
            title: Text(title ?? ''),
            content: Text(body ?? ''),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(Messaging.openContext, rootNavigator: true).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Inicializar plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        // Aquí debemos usar una pantalla válida
        await Navigator.push(
          Messaging.openContext,
          MaterialPageRoute(
            builder: (_) => Screen(text: details.payload ?? ''),
          ),
        );
      },
    );
  }

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Channel Title',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      color: Colors.blue,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // ID de la notificación
      'Test Notification', // Título
      'This is a test notification!', // Mensaje
      platformDetails,
      payload: 'Test Payload', // Información adicional que puede ser útil para la navegación
    );
  }



}

// Define la clase Screen (una página de ejemplo)
class Screen extends StatelessWidget {
  final String text;
  const Screen({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Detail')),
      body: Center(
        child: Text(text),
      ),
    );
  }
}



