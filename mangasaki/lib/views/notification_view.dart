import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mangasaki/widgets/invitation_widget.dart';

import '../connection/api_service.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<Map<String, dynamic>> friendRequests = []; // Guardamos el objeto completo de la notificación
  Map<String, Uint8List> userImages = {};
  Timer? _timer;
  final int userId = 1;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _loadNotifications());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      // Obtener las notificaciones
      final notifications = await ApiService().getNotifications(userId);

      // Acceder a la lista 'data' que contiene las notificaciones
      final List<dynamic> data = notifications['data'];
      setState(() {
        friendRequests = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print("Error al cargar notificaciones: $e");
    }
  }

  Future<Uint8List> getUserImage(String nickname) async {
    if (userImages.containsKey(nickname)) {
      return userImages[nickname]!; // Devuelve la imagen si ya está almacenada
    }
    try {
      final image = await ApiService().getUserImage(nickname);
      userImages[nickname] = image; // Guardar la imagen en el mapa
      return image;
    } catch (e) {
      throw Exception("Error al cargar la imagen del usuario");
    }
  }

  void _showDeclineDialog(int notificationId, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: Text('Do you really want to decline the friend request from $username?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Si el usuario cancela, cerramos el diálogo
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Si acepta, se llama a la API para rechazar la solicitud
                await ApiService().declineFriendRequest(notificationId);
                setState(() {
                  // Eliminamos la solicitud rechazada de la lista
                  friendRequests.removeWhere((notif) => notif['id'] == notificationId);
                });
                Navigator.of(context).pop(); // Cerramos el diálogo
              },
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Notifications", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 60, 111, 150),
        child: _buildMobileList(),
      ),
    );
  }

  Widget _buildMobileList() {
    if (friendRequests.isEmpty) {
      return const Center(child: Text("No notifications", style: TextStyle(color: Colors.white)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: friendRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notif = friendRequests[index];
        final username = notif['message'].split(' ').first; // Obtener la primera palabra del mensaje
        final notificationId = notif['id'];

        return FutureBuilder<Uint8List>(
          future: getUserImage(username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Text('Error al cargar la imagen');
            } else if (snapshot.hasData) {
              return InvitationWidget(
                username: username,
                profileImageUrl: snapshot.data!,
                onAccept: () {
                  print("$username accepted");
                },
                onDecline: () {
                  _showDeclineDialog(notificationId, username);
                },
              );
            } else {
              return const Text('No se pudo cargar la imagen');
            }
          },
        );
      },
    );
  }
}
