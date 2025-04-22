import 'package:flutter/material.dart';

class DetailsProfileView extends StatelessWidget {
  final String? collectionName;

  final List<Map<String, dynamic>> userMangas = [
    {
      "title": "One Piece",
      "author": "Eiichiro Oda",
      "chapters": 1090,
      "status": "En publicación",
    },
    {
      "title": "Naruto",
      "author": "Masashi Kishimoto",
      "chapters": 700,
      "status": "Finalizado",
    },
    {
      "title": "Attack on Titan",
      "author": "Hajime Isayama",
      "chapters": 139,
      "status": "Finalizado",
    },
    {
      "title": "Death Note",
      "author": "Tsugumi Ohba",
      "chapters": 108,
      "status": "Finalizado",
    },
  ];

  DetailsProfileView({super.key, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 60, 111, 150),
      appBar: AppBar(
        title: Text(
          collectionName!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            color: Colors.white,
            onPressed: () {
              // Compartir colección
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: userMangas.length,
        itemBuilder: (context, index) {
          final manga = userMangas[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manga["title"],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Autor: ${manga["author"]}",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  "Capítulos: ${manga["chapters"]}",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  "Estado: ${manga["status"]}",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
