import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../connection/api_service.dart';
import '../connection/app_data.dart';
import '../views/login_view.dart';
import '../views/manga_view.dart';
import '../views/notification_view.dart';


/// Widget para mostrar una solicitud de amistad entrante con opciones para
/// aceptarla o rechazarla.
class InvitationWidget extends StatefulWidget {
  final String username;
  final Uint8List profileImageUrl;
  final String message;
  final String type;
  final int notificationId;

  const InvitationWidget({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.message,
    required this.type,
    required this.notificationId,
  });

  @override
  State<InvitationWidget> createState() => _InvitationWidgetState();
}


class _InvitationWidgetState extends State<InvitationWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: MemoryImage(widget.profileImageUrl)),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.message, style: const TextStyle(fontSize: 16))),
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.green),
            onPressed: () => _showAcceptFriendDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _showDeclineFriendDialog(),
          ),
        ],
      ),
    );
  }

  void _showAcceptFriendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Friendship'),
          content: Text('Do you want to accept the friend request from ${widget.username}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final usuario = await ApiService().getUserInfo(LoginScreen.username);
                final fromId = usuario["resultat"]["id"];

                Map<String, dynamic> messageData = {
                  "type": "friend_notification",
                  "sender_user_id": fromId,
                  "receiver_username": widget.username,
                };

                String messageJson = jsonEncode(messageData);
                final appData = Provider.of<AppData>(context, listen: false);
                appData.sendMessage(messageJson);

                setState(() {
                  NotificationView.friendRequests.removeWhere(
                        (notif) => notif['id'] == widget.notificationId,
                  );
                });

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void _showDeclineFriendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: Text('Do you really want to decline the friend request from ${widget.username}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await ApiService().declineFriendRequest(widget.notificationId);
                setState(() {
                  NotificationView.friendRequests.removeWhere(
                        (notif) => notif['id'] == widget.notificationId,
                  );
                });
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("The notification has been successfully removed."), backgroundColor: Colors.green,),
                );
                // Notificar al padre que recargue
                if (context.findAncestorStateOfType<NotificationViewState>() != null) {
                  context.findAncestorStateOfType<NotificationViewState>()!.loadNotifications();
                }
              },
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
  }
}


/// Widget que muestra una notificación de amistad aceptada, con opción de eliminarla.
class FriendAcceptedWidget extends StatelessWidget {
  final String username;
  final Uint8List profileImageUrl;
  final String message;
  final int notificationId;
  final String type;

  const FriendAcceptedWidget({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.message,
    required this.notificationId, required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: MemoryImage(profileImageUrl), radius: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () async {
              await ApiService().deleteNotification(notificationId, type);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("The notification has been successfully removed."), backgroundColor: Colors.green,),
              );
              // Notificar al padre que recargue
              if (context.findAncestorStateOfType<NotificationViewState>() != null) {
                context.findAncestorStateOfType<NotificationViewState>()!.loadNotifications();
              }
            },
          )
        ],
      ),
    );
  }
}

class RecommendationWidget extends StatelessWidget {
  final String username;
  final Uint8List profileImageUrl;
  final String message;
  final int notificationId;
  final String type;

  const RecommendationWidget({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.message,
    required this.notificationId,
    required this.type,
  });

  /// Extrae el ID numérico del manga entre comillas en el mensaje
  int? _extractMangaId(String message) {
    final RegExp exp = RegExp(r'"(\d+)"');
    final match = exp.firstMatch(message);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Reemplaza el ID por el título real del manga
  Future<String> replaceMangaIdWithTitle(String message) async {
    final mangaId = _extractMangaId(message);
    if (mangaId != null) {
      try {
        final mangaData = await ApiService().searchManga(mangaId);
        final title = mangaData['title'];
        return message.replaceFirst('"$mangaId"', '"$title"');
      } catch (_) {
        return message;
      }
    }
    return message;
  }

  Widget _buildFormattedMessage(String message, String title) {
    // Dividir el mensaje por el título para insertar el estilo
    final parts = message.split('"$title"');

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),

      child: Row(
        children: [
          CircleAvatar(backgroundImage: MemoryImage(profileImageUrl), radius: 24),
          const SizedBox(width: 12),

          Expanded(
            child: FutureBuilder<String>(
              future: replaceMangaIdWithTitle(message),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // o un skeleton
                } else if (snapshot.hasError) {
                  return Text(message);
                } else {
                  final modifiedMessage = snapshot.data!;
                  final RegExp titleExp = RegExp(r'"([^"]+)"');
                  final match = titleExp.firstMatch(modifiedMessage);
                  final title = match?.group(1) ?? '';
                  return _buildFormattedMessage(modifiedMessage, title);
                }
              },
            ),
          ),

          IconButton(
            icon: const Icon(Icons.article, color: Colors.green),
            onPressed: () async {
              final mangaId = _extractMangaId(message);
              if (mangaId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No se pudo obtener el manga recomendado.")),
                );
                return;
              }

              try {
                final mangaData = await ApiService().searchManga(mangaId);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MangaView(
                      name: mangaData["title"],
                      description: mangaData["description"].replaceAll(RegExp(r'(\n|\[Written by MAL Rewrite\])'), '').trim(),
                      status: mangaData["status"],
                      ranking: mangaData["rank"],
                      score: mangaData["score"],
                      genres: mangaData["genres"],
                      chapters: mangaData["chapters"] ?? -1,
                      imageUrl: mangaData["imageUrl"],
                      id: mangaData["id"],
                    ),
                  ),
                );

                // Eliminar notificación
                (context as Element).markNeedsBuild();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error al cargar manga: $e")),
                );
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () async {
              await ApiService().deleteNotification(notificationId, type);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("The notification has been successfully removed."), backgroundColor: Colors.green,),
              );
              // Notificar al padre que recargue
              if (context.findAncestorStateOfType<NotificationViewState>() != null) {
                context.findAncestorStateOfType<NotificationViewState>()!.loadNotifications();
              }
            },
          )
        ],
      ),
    );
  }
}




/// Widget que muestra una notificación de "me gusta", con opción de descartarla.
class LikeNotificationWidget extends StatelessWidget {
  final String username;
  final Uint8List profileImageUrl;
  final String message;
  final int notificationId;
  final String type;

  const LikeNotificationWidget({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.message,
    required this.notificationId, required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: MemoryImage(profileImageUrl), radius: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () async {
              await ApiService().deleteNotification(notificationId, type);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("The notification has been successfully removed."), backgroundColor: Colors.green,),
              );
              // Notificar al padre que recargue
              if (context.findAncestorStateOfType<NotificationViewState>() != null) {
                context.findAncestorStateOfType<NotificationViewState>()!.loadNotifications();
              }
            },
          )
        ],
      ),
    );
  }
}
