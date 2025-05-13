import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  static bool disconnectedForUser = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  AppData();

  void connectToWebSocket() {
    if (connectionStatus == ConnectionStatus.connected || connectionStatus == ConnectionStatus.connecting) {
      print("Ya estás conectado o intentando conectar.");
      return;
    }

    connectionStatus = ConnectionStatus.connecting;
    notifyListeners();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      connectionStatus = ConnectionStatus.connected;
      isConnected = true;
      _reconnectAttempts = 0; // Reset reconnection attempts
      notifyListeners();

      _channel!.stream.listen(
            (message) => _onMessageReceived(message),
        onError: (error) {
          print("❌ WebSocket error: $error");
          _handleDisconnection();
        },
        onDone: () {
          print("⚠️ WebSocket cerrado. Código: ${_channel!.closeCode}, Razón: ${_channel!.closeReason}");
          _handleDisconnection();
        },
      );

      print("✅ Conexión establecida.");
    } catch (e) {
      print("❌ Error al conectar: $e");
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

    // 👉 Verifica si la desconexión fue iniciada por el usuario
    if (disconnectedForUser) {
      print("🛑 Desconectado manualmente por el usuario. No se intentará reconectar.");
      return;
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print("❌ Máximo de intentos de reconexión alcanzado. Deteniendo intentos.");
      return;
    }

    int delaySeconds = 5 * (_reconnectAttempts + 1); // backoff exponencial simple
    _reconnectAttempts++;

    print("🔁 Reintentando conexión en $delaySeconds segundos (intento $_reconnectAttempts de $_maxReconnectAttempts)");

    Future.delayed(Duration(seconds: delaySeconds), () {
      connectToWebSocket();
    });
  }


  void sendMessage(String message) {
    if (_channel == null || connectionStatus != ConnectionStatus.connected) {
      print("❌ No conectado. Mensaje no enviado.");
      print("Estado de conexión: $connectionStatus");

      if (connectionStatus == ConnectionStatus.disconnected) {
        print("🔄 Reintentando conexión...");
        connectToWebSocket();
      }
      return;
    }
    _channel!.sink.add(message);
    print("✅ Mensaje enviado: $message");
  }

  void _onMessageReceived(String message) async {
    await Future.delayed(Duration(milliseconds: 500));

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
          print("🔄 joinedClientWithInfoResponse recibido.");
          final userData = await UserStorage.getUserData();
          if (userData != null && userData.containsKey("resultat")) {
            final username = userData["resultat"]["nickname"];
            requestFriendsList(username);
          }
          break;

        case "amigosOnlineOfflineCompartidos":
          print("🤝 Lista de amigos recibida.");
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
        case "notificationSent":
          print(data);

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
      } else {
        NotificationRepository.showTestNotification(data["data"]["message"]);
      }
    } else if (subtype == "friend") {
      if (Platform.isWindows || Platform.isLinux) {
        Uint8List image = await ApiService().getUserImage(data["data"]["sender_nickname"]);
        NotificationRepository.showMessageStyleNotification(data["data"]["message"], image);
      } else {
        NotificationRepository.showTestNotification(data["data"]["message"]);
      }
    } else if (subtype == "like") {
      if (Platform.isWindows || Platform.isLinux) {
        Uint8List image = await ApiService().getUserImage(data["data"]["sender_nickname"]);
        NotificationRepository.showMessageStyleNotification(data["data"]["message"], image);
      } else {
        NotificationRepository.showTestNotification(data["data"]["message"]);
      }
    } else if (subtype == "recommendation") {
      if (Platform.isWindows || Platform.isLinux) {
        Uint8List image = await ApiService().getUserImage(data["data"]["sender_nickname"]);
        NotificationRepository.showMessageStyleNotification(data["data"]["message"], image);
      } else {
        NotificationRepository.showTestNotification(data["data"]["message"]);
      }
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

