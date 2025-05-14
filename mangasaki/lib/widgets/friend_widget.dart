import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../connection/api_service.dart';
import '../views/profileFriend_view.dart';

class friendWidget extends StatelessWidget {
  final String username;
  final Uint8List? image;
  final bool online;
  final int friendId;
  final Function func;

  const friendWidget({
    Key? key,
    required this.username,
    required this.image,
    required this.online,
    required this.friendId, required this.func
  }) : super();

  @override
  Widget build(BuildContext context) {
    final backgroundColor = online ? Colors.green[50] : Colors.red[50];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen de perfil
          CircleAvatar(
            radius: 24,
            backgroundImage: image != null ? MemoryImage(image!) : null,
            backgroundColor: Colors.grey[300],
          ),


          SizedBox(width: 12),

          // Nombre de usuario
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Icono de perfil
          IconButton(
            icon: Icon(Icons.person, color: Colors.blueAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileFriendView(nickname: username),
                ),
              );
            },
          ),

          // Icono de eliminar
          IconButton(
            icon: Icon(Icons.close, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Remove Friend'),
                    content: Text('Are you sure you want to remove $username as a friend?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra el diálogo
                        },
                      ),
                      TextButton(
                        child: Text('Remove'),
                        onPressed: () async {
                          Navigator.of(context).pop(); // Cierra el diálogo
                          try {
                            print(friendId);
                            final result = await ApiService().deleteFriendship(friendId);
                            func();
                          } catch (e) {
                            print('Error: $e');
                            // Muestra error si es necesario
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),

        ],
      ),
    );
  }
}
