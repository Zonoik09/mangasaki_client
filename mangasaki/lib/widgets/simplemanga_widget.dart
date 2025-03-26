import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mangasaki/views/manga_view.dart';

class SimpleMangaWidget extends StatefulWidget {
  final int id;
  final String title;
  final String imageUrl;

  const SimpleMangaWidget({
    Key? key,
    required this.id,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _SimpleMangaWidgetState createState() => _SimpleMangaWidgetState();
}

class _SimpleMangaWidgetState extends State<SimpleMangaWidget> {
  Map<dynamic, dynamic>? mangaData;
  bool isLoading = false;

  Future<void> fetchMangaDetails() async {
    if (mangaData != null) {
      navigateToMangaView();
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await getManga(widget.id);
      setState(() {
        mangaData = data;
        isLoading = false;
      });
      navigateToMangaView();
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos. Inténtalo de nuevo.')),
      );
    }
  }

  Future<Map<dynamic, dynamic>> getManga(int id) async {
    final response = await http.get(
        Uri.parse("https://api.jikan.moe/v4/manga/$id/full"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to load manga details');
    }
  }

  void navigateToMangaView() {
    if (mangaData == null) return;

    String cleanedDescription = (mangaData!['synopsis'] ??
        'No description available')
        .replaceAll(RegExp(r'(\n|\[Written by MAL Rewrite\])'), '')
        .trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MangaView(
              name: widget.title,
              description: cleanedDescription,
              status: mangaData!['status'] ?? 'Unknown',
              ranking: mangaData!['rank'] ?? 0,
              score: mangaData!['score'] ?? 0.0,
              genres: (mangaData!['genres'] as List)
                  .map((genre) => genre['name'] as String)
                  .toList(),
              chapters: mangaData!['chapters'] ?? -1,
              imageUrl: widget.imageUrl,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: fetchMangaDetails,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth - 200 - 50;

          return Card(
            color: Color.fromARGB(255, 60, 111, 150),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Image.network(widget.imageUrl, height: 230,
                    width: 150,
                    fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: availableWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
                        if (isLoading) const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}