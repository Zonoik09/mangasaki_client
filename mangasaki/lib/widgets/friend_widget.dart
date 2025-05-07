import 'package:flutter/material.dart';

class friendWidget extends StatelessWidget {
  final String username;
  final String image;
  final bool online;

  const friendWidget({
    Key? key,
    required this.username,
    required this.image,
    required this.online,
  }) : super(key: key);

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
            backgroundImage: NetworkImage(image),
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
              // Acción para ver perfil
            },
          ),

          // Icono de eliminar
          IconButton(
            icon: Icon(Icons.close, color: Colors.redAccent),
            onPressed: () {
              // Acción para eliminar
            },
          ),
        ],
      ),
    );
  }
}
