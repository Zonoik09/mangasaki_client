import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';




class Messaging {
  static late BuildContext openContext; // Se asigna desde main()
}

class NotificationRepository {

  static final WindowsNotification _winNotifyPlugin = WindowsNotification(
    applicationId: r"{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}\WindowsPowerShell\v1.0\powershell.exe",
  );

  static Future<void> initWindowsNotifications() async {
    _winNotifyPlugin.initNotificationCallBack((s) {
    });
  }

  static Future<String> getImageBytes(String url) async {
    final supportDir = await getApplicationSupportDirectory();
    final response = await http.get(Uri.parse(url));
    final file = File("${supportDir.path}/${DateTime.now().millisecondsSinceEpoch}.png");
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  static Future<void> showMessageStyleNotification(String mensaje, Uint8List imageFuture) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/notificacion_imagen.png';
    final file = File(filePath);

    final imageBytes = await imageFuture;

    await file.writeAsBytes(imageBytes);

    NotificationMessage message = NotificationMessage.fromPluginTemplate(
      "New Message",
      "New Message",
      mensaje,
      image: filePath,
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

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> notificationPlugin() async {
    await _requestPermissions();

    // Crear canal de notificación en Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Solicitar permisos explícitos en iOS
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

    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
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

    // Unificar configuración
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Inicializar plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        await Navigator.push(
          Messaging.openContext,
          MaterialPageRoute(
            builder: (_) => Screen(text: details.payload ?? ''),
          ),
        );
      },
    );
  }


  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static Future<void> showTestNotification(String mensaje) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Channel Title',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      color: Colors.blue,
      playSound: true,
      icon: '@drawable/splash_logo',
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

    int notificationId = DateTime.now().millisecondsSinceEpoch % 2147483647;


    await flutterLocalNotificationsPlugin.show(
      notificationId,
      'Mangasaki',
      mensaje,
      platformDetails,
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



