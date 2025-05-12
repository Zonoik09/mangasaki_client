import 'package:flutter/material.dart';
import 'dart:typed_data';


class InvitationWidget extends StatelessWidget {
  final String username;
  final Uint8List profileImageUrl;
  final String message;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String type;

  const InvitationWidget({
    Key? key,
    required this.username,
    required this.profileImageUrl,
    required this.onAccept,
    required this.onDecline,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de perfil
          CircleAvatar(
            radius: 24,
            backgroundImage: MemoryImage(profileImageUrl),
          ),
          const SizedBox(width: 12),

          // Texto expandido
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
            ),
          ),

          // Botones
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.green),
            onPressed: onAccept,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onDecline,
          ),
        ],
      ),
    );
  }
}
