import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;

import '../widgets/manga_widget.dart';

class TopMangasView extends StatefulWidget {
  @override
  _TopMangasViewState createState() => _TopMangasViewState();
}

class _TopMangasViewState extends State<TopMangasView> {
  Future<List<dynamic>>? _mangasFuture;
  int _lastPage = 1;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _mangasFuture = fetchTopMangas();
  }

  Future<List<dynamic>> fetchTopMangas() async {
    return await getTopMangas(_currentPage);
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
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.black,
            onPressed: _retryFetchMangas,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
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
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
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

                          return SizedBox(
                            height: 200,
                            child: width < 800
                                ? MangaWidgetMobile(
                              title: manga['title'],
                              imageUrl: manga['images']['jpg']['image_url'],
                              status: manga['status'],
                              score: manga['score'] ?? 0,
                              rank: manga['rank'] ?? 99999,
                              description: manga['synopsis'] ?? 'N/A',
                              chapters: manga["chapters"] ?? -1,
                              genres: generos,
                              type: manga["type"],
                            )
                                : MangaWidget(
                              title: manga['title'],
                              imageUrl: manga['images']['jpg']['image_url'],
                              status: manga['status'],
                              score: manga['score'] ?? 0,
                              rank: manga['rank'] ?? 99999,
                              description: manga['synopsis'] ?? 'N/A',
                              chapters: manga["chapters"] ?? -1,
                              genres: generos,
                              type: manga["type"],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.first_page),
                onPressed: _currentPage > 1 ? () => _changePage(1) : null,
              ),
              IconButton(
                icon: Icon(Icons.navigate_before),
                onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
              ),
              Text('Page $_currentPage of $_lastPage'),
              IconButton(
                icon: Icon(Icons.navigate_next),
                onPressed: _currentPage < _lastPage ? () => _changePage(_currentPage + 1) : null,
              ),
              IconButton(
                icon: Icon(Icons.last_page),
                onPressed: _currentPage < _lastPage ? () => _changePage(_lastPage) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _changePage(int newPage) {
    if (newPage >= 1 && newPage <= _lastPage) {
      setState(() {
        _currentPage = newPage;
        _mangasFuture = getTopMangas(newPage);
      });
    }
  }


  Future<List<dynamic>> getTopMangas(int page) async {
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/top/manga?limit=24&page=$page'));
    print('https://api.jikan.moe/v4/top/manga?limit=24&page=$page');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        _lastPage = data['pagination']['last_visible_page'] ?? 1;
      });
      return data['data'];
    } else {
      throw Exception('Failed to load top mangas');
    }
  }

}
