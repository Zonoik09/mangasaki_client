import 'package:flutter/material.dart';

class MangaView extends StatelessWidget {
  final String name;
  final String description;
  final String status;
  final int ranking;
  final double score;
  final List<String> genres;
  final int chapters;
  final String imageUrl;


  const MangaView({
    Key? key,
    required this.name,
    required this.description,
    required this.status,
    required this.ranking,
    required this.score,
    required this.genres,
    required this.chapters,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Text("Estado: $status"),
            Text("Ranking: #$ranking"),
            Text("Score: $score"),
            Text("Géneros: ${genres.join(", ")}"),
            Text("Capítulos: $chapters"),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: chapters,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("$name - Capítulo ${index + 1}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.favorite_border),
                        SizedBox(width: 8),
                        Icon(Icons.bookmark_border),
                        SizedBox(width: 8),
                        Icon(Icons.remove_red_eye),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
