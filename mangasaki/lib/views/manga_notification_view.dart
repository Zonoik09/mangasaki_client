import 'package:flutter/material.dart';
import 'manga_view.dart';

class MangaNotificationView extends StatelessWidget {
  final String name;
  final String description;
  final String status;
  final int ranking;
  final double score;
  final List<String> genres;
  final String imageUrl;
  final int chapters;
  final int id;

  const MangaNotificationView({
    Key? key,
    required this.name,
    required this.description,
    required this.status,
    required this.ranking,
    required this.score,
    required this.genres,
    required this.imageUrl,
    required this.chapters,
    required this.id,
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MangaView(name: name, description: description, status: status, ranking: ranking, score: score , genres: genres, chapters: 30,imageUrl: imageUrl,id: id,)),
                  );
                },
                child: const Text("Ver Manga"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
