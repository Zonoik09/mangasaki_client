import 'package:flutter/material.dart';

class InvitationWidgetMobile extends StatelessWidget {
  final String username;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InvitationWidgetMobile({
    Key? key,
    required this.username,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "$username has sent you a friend request",
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          _buildButton("Accept", Colors.green, onAccept),
          const SizedBox(width: 8),
          _buildButton("Decline", Colors.red, onDecline),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class InvitationWidgetDesktop extends StatelessWidget {
  final String username;
  final String profileImageUrl;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InvitationWidgetDesktop({
    Key? key,
    required this.username,
    required this.profileImageUrl,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Ancho fijo para escritorio
      height: 400, // Altura fija para mantener el widget constante
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen proporcional que se ajusta al tamaño disponible
          LayoutBuilder(
            builder: (context, constraints) {
              double imageSize = constraints.maxWidth * 0.4; // La imagen ocupará el 40% del ancho disponible
              return CircleAvatar(
                radius: imageSize / 2, // El radio es proporcional al tamaño calculado
                backgroundImage: NetworkImage(profileImageUrl),
              );
            },
          ),
          const SizedBox(height: 12), // Espacio entre la imagen y la descripción

          // Descripción debajo de la imagen
          Expanded(
            child: Center(
              child: Text(
                "$username has sent you a friend request",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                maxLines: 2, // Limita a 2 líneas para evitar desbordamientos
                overflow: TextOverflow.ellipsis, // Asegura que el texto no se desborde
              ),
            ),
          ),

          // Espacio entre la descripción y los botones
          const SizedBox(height: 12),

          // Botones alineados al fondo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de aceptar menos ancho
              _buildButton("Accept", Colors.green, onAccept),
              // Botón de rechazar menos ancho
              _buildButton("Decline", Colors.red, onDecline),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para el botón
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 82, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

