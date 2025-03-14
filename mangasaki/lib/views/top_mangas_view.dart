import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/manga_widget.dart';

class TopMangasView extends StatefulWidget {
  @override
  _TopMangasViewState createState() => _TopMangasViewState();
}

class _TopMangasViewState extends State<TopMangasView> {
  Future<List<dynamic>> fetchTopMangas() async {
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/top/manga?limit=24'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load top mangas');
    }
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
            icon: Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchTopMangas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading top mangas"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No mangas found"));
          }

          final mangas = snapshot.data!;
          int crossAxisCount = MediaQuery.of(context).size.width > 800 ? 3 : 1;
          // Obtener la altura total de la pantalla
          double screenHeight = MediaQuery.of(context).size.height;
          // Calcular el childAspectRatio (ancho/alto) basado en la altura del 10% de la pantalla
          double childAspectRatio = MediaQuery.of(context).size.width / (screenHeight * 0.6);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Definir número de columnas
                crossAxisSpacing: 10,            // Espaciado entre columnas
                mainAxisSpacing: 10,             // Espaciado entre filas
                childAspectRatio: childAspectRatio, // Ajusta el aspecto de las celdas
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
              },
            ),
          );
        },
      ),
    );
  }
}
