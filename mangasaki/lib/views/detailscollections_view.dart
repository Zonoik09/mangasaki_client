import 'package:flutter/material.dart';

import '../widgets/manga_widget.dart';

class DetailsProfileView extends StatelessWidget {
  final String? collectionName;

  final List<Map<String, dynamic>> userMangas = [
    {
      "title": "One Piece",
      "author": "Eiichiro Oda",
      "chapters": 1090,
      "status": "Publishing",
      "imageUrl": "https://cdn.myanimelist.net/images/manga/1/105683.jpg",
      "description": "Un joven con sombrero de paja busca el tesoro legendario.",
      "score": 9.1,
      "rank": 1,
      "genres": ["Adventure", "Action"],
      "type": "Manga",
    },
    {
      "title": "Naruto",
      "author": "Masashi Kishimoto",
      "chapters": 700,
      "status": "Finished",
      "imageUrl": "https://cdn.myanimelist.net/images/manga/1/105683.jpg",
      "description": "Un ninja con el sueño de ser Hokage.",
      "score": 8.5,
      "rank": 12,
      "genres": ["Action", "Fantasy"],
      "type": "Manga",
    },
    // Agrega más si deseas
  ];

  DetailsProfileView({super.key, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          collectionName ?? "Detalles",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        iconTheme: const IconThemeData(color: Colors.white), // <- Esta línea
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            color: Colors.white,
            onPressed: () {
              // Acción de compartir
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: userMangas.length,
        itemBuilder: (context, index) {
          final manga = userMangas[index];
          final bool isMobile = MediaQuery.of(context).size.width < 600;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 250, // Limita la altura para evitar errores de layout
              child: isMobile
                  ? MangaWidgetMobile(
                title: manga['title'],
                imageUrl: manga['imageUrl'],
                status: manga['status'],
                score: manga['score'],
                rank: manga['rank'],
                description: manga['description'],
                chapters: manga['chapters'],
                genres: List<String>.from(manga['genres']),
                type: manga['type'],
              )
                  : MangaWidget(
                title: manga['title'],
                imageUrl: manga['imageUrl'],
                status: manga['status'],
                score: manga['score'],
                rank: manga['rank'],
                description: manga['description'],
                chapters: manga['chapters'],
                genres: List<String>.from(manga['genres']),
                type: manga['type'],
              ),
            ),
          );
        },
      ),
    );
  }
}
