import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'NotificationRepository.dart';
import 'api_service.dart';
import 'friendManager.dart';
import 'userStorage.dart';

enum ConnectionStatus { disconnected, disconnecting, connecting, connected }

class AppData extends ChangeNotifier {
  final String _serverUrl = "wss://mangasaki.ieti.site/ws";
  WebSocketChannel? _channel;
  String? socketId;
  bool isConnected = false;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  // Variables de reconexión eliminadas

  AppData();

  // Metodo para iniciar la conexión al WebSocket
  void connectToWebSocket() {
    if (connectionStatus == ConnectionStatus.connected) {
      print("Ya estás conectado. No intentamos reconectar.");
      return;
    }

    connectionStatus = ConnectionStatus.connecting;
    notifyListeners();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      connectionStatus = ConnectionStatus.connected;
      isConnected = true;
      notifyListeners();

      _channel!.stream.listen(
            (message) {
          _onMessageReceived(message);
        },
        onError: (error) {
          print("WebSocket error: $error");
          _handleDisconnection();
        },
        onDone: () {
          print("WebSocket cerrado");
          _handleDisconnection();
        },
      );
      print("Conexión establecida.");
    } catch (e) {
      print("Error al conectar: $e");
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    if (_channel != null) {
      _channel!.sink.close();
    }
    connectionStatus = ConnectionStatus.disconnected;
    isConnected = false;
    notifyListeners();

    // Intenta reconectar después de un retraso
    Future.delayed(Duration(seconds: 5), () {
      print("Reintentando conexión...");
      connectToWebSocket();
    });
  }

  void sendMessage(String message) {
    if (_channel == null || connectionStatus != ConnectionStatus.connected) {
      print("❌ No conectado. Mensaje no enviado.");
      print("Estado de conexión: $connectionStatus");

      // Intentar reconectar si no estás conectado
      if (connectionStatus == ConnectionStatus.disconnected) {
        print("🔄 Reintentando conexión...");
        connectToWebSocket();
      }

      return; // No enviar el mensaje si no estamos conectados.
    }

    _channel!.sink.add(message);
    print("✅ Mensaje enviado: $message");
  }




  void _onMessageReceived(String message) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simula carga

    try {
      final data = jsonDecode(message);
      if (data is! Map<String, dynamic> || !data.containsKey("type")) return;

      switch (data["type"]) {
        case "welcome":
          socketId = data["id"];
          print("🟢 Conectado al servidor con ID: $socketId");

          final userData = await UserStorage.getUserData();
          if (userData != null && userData.containsKey("resultat")) {
            final username = userData["resultat"]["nickname"];
            final joinedMessage = jsonEncode({
              "type": "joinedClientWithInfo",
              "id": socketId,
              "username": username,
            });
            sendMessage(joinedMessage);
          } else {
            print("⚠️ No se encontró nombre de usuario.");
          }
          break;

        case "joinedClientWithInfoResponse":
          print("🔄 Respuesta de joinedClientWithInfoResponse recibida.");
          final userData = await UserStorage.getUserData();
          if (userData != null && userData.containsKey("resultat")) {
            final username = userData["resultat"]["nickname"];
            requestFriendsList(username); // <- Aquí llamas para que los pida
          }
          break;

        case "amigosOnlineOfflineCompartidos":
          print("🤝 Lista de amigos recibida.");
          print(data["data"]);
          FriendManager().updateFriends(data["data"]);
          break;

        case "ping":
          print("📡 Ping recibido del servidor.");
          break;

        case "newClient":
          print("🆕 Nuevo cliente conectado.");
          break;

        case "notification":
          await _handleNotification(data);
          break;

        default:
          print("ℹ️ Tipo de mensaje no manejado: ${data["type"]}");
      }
    } catch (e) {
      print("❌ Error al procesar mensaje: $e");
    }
  }

  Future<void> _handleNotification(Map<String, dynamic> data) async {
    final subtype = data["subtype"];
    final detail = data["detail"];

    if (subtype == "friend_request") {
      if (Platform.isWindows || Platform.isLinux) {
        Uint8List image = await ApiService().getUserImage(data["data"]["sender_nickname"]);
        NotificationRepository.showMessageStyleNotification(data["data"]["message"], image);
      }
      else {
        NotificationRepository.showTestNotification(data["data"]["message"]);
      }
    } else if (subtype == "friend") {
      // Notificación de amistad aceptada
      print("✅ Solicitud de amistad aceptada.");
    } else if (subtype == "like") {
      print("👍 Notificación de like recibida.");
    } else if (subtype == "recommendation") {
      print("📌 Recomendación recibida.");
    }

    if (detail == "notificationSent") {
      print("📬 Notificación enviada confirmada por servidor.");
    }
  }

  void requestFriendsList(String username) {
    final message = jsonEncode({
      "type": "getFriendsOnlineOffline",
      "username": username,
    });
    sendMessage(message);
  }

}
