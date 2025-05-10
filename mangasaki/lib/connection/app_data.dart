import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'utils_websockets.dart';

class AppData extends ChangeNotifier {
  // Atributs per gestionar la connexió
  final WebSocketsHandler _wsHandler = WebSocketsHandler();
  final String _wsServer = "mangasaki.ieti.site/ws";
  final int _wsPort = 3000;
  bool isConnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = Duration(seconds: 3);

  AppData() {
    _connectToWebSocket();
  }


  // Connectar amb el servidor (amb reintents si falla)
  void _connectToWebSocket() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        print("S'ha assolit el màxim d'intents de reconnexió.");
      }
      return;
    }

    isConnected = false;
    notifyListeners();

    _wsHandler.connectToServer(
      _wsServer,
      _wsPort,
      _onWebSocketMessage,
      onError: _onWebSocketError,
      onDone: _onWebSocketClosed,
    );

    isConnected = true;
    _reconnectAttempts = 0;
    notifyListeners();
  }

  // Tractar un missatge rebut des del servidor
  void _onWebSocketMessage(String message) {
    try {
      var data = jsonDecode(message);
    } catch (e) {
      if (kDebugMode) {
        print("Error processant missatge WebSocket: $e");
      }
    }
  }

  // Tractar els errors de connexió
  void _onWebSocketError(dynamic error) {
    if (kDebugMode) {
      print("Error de WebSocket: $error");
    }
    isConnected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  // Tractar les desconnexions
  void _onWebSocketClosed() {
    if (kDebugMode) {
      print("WebSocket tancat. Intentant reconnectar...");
    }
    isConnected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  // Programar una reconnexió (en cas que hagi fallat)
  void _scheduleReconnect() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      if (kDebugMode) {
        print(
          "Intent de reconnexió #$_reconnectAttempts en ${_reconnectDelay.inSeconds} segons...",
        );
      }
      Future.delayed(_reconnectDelay, () {
        //_connectToWebSocket();
      });
    } else {
      if (kDebugMode) {
        print(
          "No es pot reconnectar al servidor després de $_maxReconnectAttempts intents.",
        );
      }
    }
  }


  // Desconnectar-se del servidor
  void disconnect() {
    _wsHandler.disconnectFromServer();
    isConnected = false;
    notifyListeners();
  }

  // Enviar un missatge al servidor
  void sendMessage(String message) {
    if (isConnected) {
      _wsHandler.sendMessage(message);
    }
  }
}
