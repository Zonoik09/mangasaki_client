import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mangasaki/connection/userStorage.dart';
import 'package:mangasaki/views/login_view.dart';

enum ConnectionStatus { disconnected, disconnecting, connecting, connected }

class WebSocketsHandler {
  late Function _callback;
  String ip = "wss://mangasaki.ieti.site/ws";
  String port = "3000";
  String? socketId;

  WebSocketChannel? _socketClient;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  void connectToServer(
    String serverIp,
    int serverPort,
    void Function(String message) callback, {
    void Function(dynamic error)? onError,
    void Function()? onDone,
  }) async {
    _callback = callback;
    ip = serverIp;
    port = serverPort.toString();

    connectionStatus = ConnectionStatus.connecting;

    try {
      _socketClient = WebSocketChannel.connect(Uri.parse("wss://$ip"));
      connectionStatus = ConnectionStatus.connected;

      _socketClient!.stream.listen(
        (message) {
          _handleMessage(message);
          _callback(message);
        },
        onError: (error) {
          connectionStatus = ConnectionStatus.disconnected;
          onError?.call(error);
        },
        onDone: () {
          connectionStatus = ConnectionStatus.disconnected;
          onDone?.call();
        },
      );
    } catch (e) {
      connectionStatus = ConnectionStatus.disconnected;
      onError?.call(e);
    }
  }

  void _handleMessage(String message) async {
    // Esperar 500 ms antes de continuar
    await Future.delayed(Duration(milliseconds: 1000));

    try {
      final data = jsonDecode(message);
      if (data is Map<String, dynamic> && data.containsKey("type")) {
        if (data["type"] == "welcome") {
          socketId = data["id"];
          if (kDebugMode) {
            print("Client ID asignado por el servidor: $socketId");
          }

          // Obtener el nombre desde SharedPreferences
          final userData = await UserStorage.getUserData();

          if (userData != null && userData.containsKey("resultat")) {
            // Acceder al nickname dentro de la estructura de userData
            final username = userData["resultat"]["nickname"];
            print("Nombre de usuario: $username");

            // Construir y enviar el mensaje con el ID y nombre de usuario
            final messageToSend = jsonEncode({
              "type": "joinedClientWithInfo",
              "id": socketId,
              "username": username,
            });

            sendMessage(messageToSend);
          } else {
            print("No se encontró el nombre de usuario.");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error procesando mensaje WebSocket: $e");
      }
    }
  }




  void sendMessage(String message) {
    print("Mensaje sendMessage");
    if (connectionStatus == ConnectionStatus.connected) {
      print("Mensaje sendMessage1");
      _socketClient!.sink.add(message);
    }
  }

  void disconnectFromServer() {
    connectionStatus = ConnectionStatus.disconnecting;
    _socketClient?.sink.close();
    connectionStatus = ConnectionStatus.disconnected;
  }
}