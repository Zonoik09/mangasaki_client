import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../views/detailscollections_view.dart';

class CollectionItemCard extends StatelessWidget {
  final String title;
  final Uint8List imagePath;
  final VoidCallback? onTap;
  final int id;
  final int likes;

  const CollectionItemCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap, required this.id, required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailsProfileView(collectionName: title, id: id, likes: likes,)),
            );
          },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 60, 111, 150),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Título (nombre del jugador/colección)
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Imagen
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imagePath,  // Usamos Image.memory para mostrar una imagen desde un Uint8List
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Texto inferior
            const Text(
              "More info",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
