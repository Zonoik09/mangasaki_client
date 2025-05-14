import 'dart:typed_data';  // Correcto, para usar Uint8List
import 'package:flutter/material.dart';

import '../views/profileFriend_view.dart';

class AddFriendWidget extends StatelessWidget {
  final String username;
  final Uint8List image;
  final VoidCallback onAddFriend;

  const AddFriendWidget({
    Key? key,
    required this.username,
    required this.image,
    required this.onAddFriend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            backgroundImage: MemoryImage(image),
            backgroundColor: Colors.grey[300],
          ),

          const SizedBox(width: 12),

          // Nombre de usuario
          Expanded(
            child: Text(
              username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          IconButton(
            icon: Icon(Icons.person, color: Colors.blueAccent),
            tooltip: 'profile of $username',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileFriendView(nickname: username),
                ),
              );
            },
          ),
          // Botón de añadir amigo
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.green),
            onPressed: onAddFriend,
            tooltip: 'Add Friends',
          ),
        ],
      ),
    );
  }
}
