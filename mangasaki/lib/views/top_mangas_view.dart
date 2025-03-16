import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/scheduler.dart';

import '../widgets/manga_widget.dart';

class TopMangasView extends StatefulWidget {
  @override
  _TopMangasViewState createState() => _TopMangasViewState();
}

class _TopMangasViewState extends State<TopMangasView> {
  Future<List<dynamic>>? _mangasFuture;

  @override
  void initState() {
    super.initState();
    _mangasFuture = fetchTopMangas();
  }

  Future<List<dynamic>> fetchTopMangas() async {
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/top/manga?limit=24'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load top mangas');
    }
  }

  void _retryFetchMangas() {
    setState(() {
      _mangasFuture = fetchTopMangas();
    });
  }

  void _showErrorSnackbar(String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Top Mangas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: _retryFetchMangas,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _mangasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            _showErrorSnackbar("Error loading top mangas, retrying...");
            Future.delayed(const Duration(seconds: 2), _retryFetchMangas);
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No mangas found"));
          }

          final mangas = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              double height = MediaQuery.of(context).size.height;

              int crossAxisCount = 1;
              if (width > 1200) {
                crossAxisCount = 3;
              } else if (width > 800) {
                crossAxisCount = 2;
              }

              double childAspectRatio = width / (height * 0.6);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: crossAxisCount < 2 ? 2.5 : childAspectRatio,
                  ),
                  itemCount: mangas.length,
                  itemBuilder: (context, index) {
                    final manga = mangas[index];
                    List<String> generos = [];

                    for (var genre in manga["genres"]) {
                      generos.add(genre['name']);
                    }
                    for (var genre in manga["themes"]) {
                      generos.add(genre["name"]);
                    }
                    for (var genre in manga["demographics"]) {
                      generos.add(genre["name"]);
                    }

                    if (crossAxisCount == 1) {
                      return MangaWidgetMobile(
                        imageUrl: manga['images']['jpg']['image_url'],
                        status: manga['status'],
                        score: manga['score'].toDouble(),
                        rank: manga['rank'],
                        title: manga['title'],
                        description: manga["synopsis"],
                        chapters: manga["chapters"] ?? -1,
                        genres: generos,
                      );
                    } else {
                      return MangaWidget(
                        imageUrl: manga['images']['jpg']['image_url'],
                        status: manga['status'],
                        score: manga['score'].toDouble(),
                        rank: manga['rank'],
                        title: manga['title'],
                        description: manga["synopsis"],
                        chapters: manga["chapters"] ?? -1,
                        genres: generos,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
