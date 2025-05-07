import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../connection/api_service.dart';
import '../widgets/MangaCollection_widget.dart';
import '../widgets/manga_widget.dart';

class DetailsProfileView extends StatefulWidget {
  final String? collectionName;
  final int id;

  DetailsProfileView({super.key, required this.collectionName, required this.id});

  @override
  _DetailsProfileViewState createState() => _DetailsProfileViewState();
}

class _DetailsProfileViewState extends State<DetailsProfileView> {
  late Future<Map<String, dynamic>> mangasFuture;

  @override
  void initState() {
    super.initState();
    // Llamada a la API para obtener los mangas
    mangasFuture = ApiService().searchManga("Naruto");
  }

  final Color headerColor = const Color.fromARGB(255, 60, 111, 150);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: headerColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila (cabecera) con color de fondo
            Container(
              width: double.infinity,
              color: headerColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://cdn.myanimelist.net/images/manga/1/105683.jpg",
                      width: 150,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nombre
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.collectionName ?? "Sin nombre",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Botones
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          pickFile(context);
                        },
                        icon: const Icon(Icons.image),
                        label: const Text("Change collection image"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: headerColor,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          ApiService().changeGalleryPicture(widget.id,"",context);
                        },
                        icon: const Icon(Icons.delete_forever),
                        label: const Text("Delete collection image"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Línea divisoria blanca para transición limpia
            Container(
              width: double.infinity,
              color: headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Divider(thickness: 1.2, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // FutureBuilder para cargar mangas desde la API
            FutureBuilder<Map<String, dynamic>>(
              future: mangasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No mangas found."));
                } else {
                  final manga = snapshot.data!;
                  final bool isMobile = MediaQuery.of(context).size.width < 600;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      height: 250,
                      child: isMobile
                          ? MangaCollectionWidgetMobile(
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
                          : MangaCollectionWidget(
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
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickFile(context) async {
    FilePickerResult? result =
    await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);
      ApiService().changeGalleryPicture(widget.id, base64String, context);
    }
  }
}
