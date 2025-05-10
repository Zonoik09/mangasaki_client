import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Si es necesario para la navegación
import 'package:mangasaki/views/manga_view.dart';

class MangaWidgetRecomendation extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;
  final double score;
  final int rank;
  final String description;
  final int chapters;
  final List<String> genres;
  final String type;
  final String nickname;
  final int id;

  const MangaWidgetRecomendation({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.score,
    required this.rank,
    required this.description,
    required this.chapters,
    required this.genres,
    required this.type,
    required this.nickname,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String cleanedDescription = description
        .replaceAll(RegExp(r'(\n|\[Written by MAL Rewrite\])'), '')
        .trim();
    String newTitle = type != "Manga" ? "$title ($type)" : title;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaView(
              name: newTitle,
              description: cleanedDescription,
              status: status,
              ranking: rank,
              score: score,
              genres: genres,
              chapters: chapters,
              imageUrl: imageUrl,
              id: id,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 200, // Establece un ancho fijo o proporcional
        child: Card(
          color: Color.fromARGB(255, 60, 111, 150),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      cleanedDescription,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Recommended by $nickname",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
