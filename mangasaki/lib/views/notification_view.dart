import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mangasaki/widgets/invitation_widget.dart';

import '../connection/api_service.dart';

class NotificationView extends StatefulWidget {
  final int? userId;

  const NotificationView({super.key, required this.userId});

  static List<Map<String, dynamic>> friendRequests = [];

  @override
  State<NotificationView> createState() => NotificationViewState();
}

class NotificationViewState extends State<NotificationView> {
  Map<String, Uint8List> userImages = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadNotifications();
    _timer = Timer.periodic(
        const Duration(seconds: 10), (_) => loadNotifications());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Obtiene las notificaciones desde la API y actualiza la lista de solicitudes de amistad.
  Future<void> loadNotifications() async {
    try {
      final notifications = await ApiService().getNotifications(widget.userId);
      final List<dynamic> data = notifications['data'];
      setState(() {
        NotificationView.friendRequests = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print("Error al cargar notificaciones: $e");
    }
  }

  /// Carga la imagen de perfil de un usuario dado su nickname. Usa caché local.
  Future<Uint8List> getUserImage(String nickname) async {
    if (userImages.containsKey(nickname)) {
      return userImages[nickname]!;
    }
    try {
      final image = await ApiService().getUserImage(nickname);
      userImages[nickname] = image;
      return image;
    } catch (e) {
      throw Exception("Error al cargar la imagen del usuario");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text("Notifications", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadNotifications,
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 60, 111, 150),
        child: _buildMobileList(),
      ),
    );
  }

  /// Construye la lista de notificaciones con distintos widgets según el tipo.
  Widget _buildMobileList() {
    if (NotificationView.friendRequests.isEmpty) {
      return const Center(
          child:
              Text("No notifications", style: TextStyle(color: Colors.white)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: NotificationView.friendRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notif = NotificationView.friendRequests[index];
        final username = notif['message'].split(' ').first;
        final notificationId = notif['id'];
        final type = notif['type'];

        return FutureBuilder<Uint8List>(
          future: getUserImage(username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Error loading image');
            }

            final image = snapshot.data!;

            switch (type) {
              case 'FRIEND_REQUEST':
                return InvitationWidget(
                  username: username,
                  profileImageUrl: image,
                  notificationId: notificationId,
                  message: notif['message'],
                  type: type,
                );
              case 'FRIEND':
                return FriendAcceptedWidget(
                  username: username,
                  profileImageUrl: image,
                  message: notif['message'],
                  notificationId: notificationId,
                  type: type,
                );
              case 'RECOMMENDATION':
                return RecommendationWidget(
                  username: username,
                  profileImageUrl: image,
                  message: notif['message'],
                  notificationId: notificationId,
                  type: type,
                );
              case 'LIKE':
                return LikeNotificationWidget(
                  username: username,
                  profileImageUrl: image,
                  message: notif['message'],
                  notificationId: notificationId,
                  type: type,
                );
              default:
                return const Text("Unknown notification type");
            }
          },
        );
      },
    );
  }
}
