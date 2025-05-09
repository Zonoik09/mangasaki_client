import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../connection/api_service.dart';
import '../widgets/MangaCollection_widget.dart';
import 'dart:typed_data';

class DetailsProfileView extends StatefulWidget {
  final String? collectionName;
  final int id;

  DetailsProfileView({super.key, required this.collectionName, required this.id});

  @override
  _DetailsProfileViewState createState() => _DetailsProfileViewState();
}

class _DetailsProfileViewState extends State<DetailsProfileView> {
  late Future<List<Map<String, dynamic>>> mangasFuture;
  late Future<Uint8List> imageFuture;

  int likesCount = 67;  // Variable local para los likes simulados
  bool hasLiked = false; // Para simular si el usuario ya ha dado like

  final Color headerColor = const Color.fromARGB(255, 60, 111, 150);

  final List<String> mangaList = [
    "Naruto",
    "One Piece",
    "Attack on Titan",
    "Demon Slayer",
    "My Hero Academia"
  ]; // Lista de mangas (puedes expandirla en el futuro)

  @override
  void initState() {
    super.initState();
    // Llamada a la función que obtiene los mangas de forma dinámica
    mangasFuture = fetchMangas();
    imageFuture = ApiService().getGalleryImage(widget.id);
  }

  // Esta función se encarga de llamar a los mangas de forma secuencial
  Future<List<Map<String, dynamic>>> fetchMangas() async {
    List<Map<String, dynamic>> mangasData = [];
    int index = 0;

    // Recorremos la lista de mangas en pares
    while (index < mangaList.length) {
      // Tomamos dos mangas a la vez (si hay más de dos)
      List<String> currentBatch = mangaList.sublist(index, (index + 2) <= mangaList.length ? index + 2 : mangaList.length);

      // Llamamos a la API para obtener los mangas de la lista actual
      for (String mangaName in currentBatch) {
        var manga = await ApiService().searchManga(mangaName);
        mangasData.add(manga); // Agregar el manga a la lista
      }

      index += 2; // Incrementamos en 2 para cargar los siguientes mangas
      await Future.delayed(const Duration(seconds: 1)); // Esperamos 1 segundo antes de la siguiente carga
    }

    return mangasData;
  }

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
            // Cabecera adaptativa
            Container(
              width: double.infinity,
              color: headerColor,
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isMobile = constraints.maxWidth < 600;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          FutureBuilder<Uint8List>(
                            future: imageFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 150,
                                  height: 200,
                                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                                );
                              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/default0.jpg',
                                    width: 150,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    snapshot.data!,
                                    width: 150,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                            },
                          ),
                          if (isMobile) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await pickFile(context);
                                  },
                                  icon: const Icon(Icons.image, color: Colors.white),
                                  tooltip: "Change image",
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await ApiService().changeGalleryPicture(widget.id, "", context);
                                    setState(() {
                                      imageFuture = ApiService().getGalleryImage(widget.id);
                                    });
                                  },
                                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                                  tooltip: "Delete image",
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.collectionName ?? "Sin nombre",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Contador de likes con botón de like
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (hasLiked) {
                                    likesCount--;
                                  } else {
                                    likesCount++;
                                  }
                                  hasLiked = !hasLiked;
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    hasLiked ? Icons.favorite : Icons.favorite_border,
                                    color: hasLiked ? Colors.red : Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$likesCount likes",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await pickFile(context);
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
                              onPressed: () async {
                                await ApiService().changeGalleryPicture(widget.id, "", context);
                                setState(() {
                                  imageFuture = ApiService().getGalleryImage(widget.id);
                                });
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
                    ],
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              color: headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Divider(thickness: 1.2, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // FutureBuilder para manejar múltiples mangas de forma dinámica
            FutureBuilder<List<Map<String, dynamic>>>(
              future: mangasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No mangas found."));
                } else {
                  List<Map<String, dynamic>> mangas = snapshot.data!;
                  final bool isMobile = MediaQuery.of(context).size.width < 600;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: mangas.map((manga) {
                        return SizedBox(
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
                        );
                      }).toList(),
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);

      await ApiService().changeGalleryPicture(widget.id, base64String, context);

      setState(() {
        imageFuture = ApiService().getGalleryImage(widget.id);
      });
    }
  }
}



/* En un momento se podra poner esto que es para las api
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.collectionName ?? "Sin nombre",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(height: 8),
      FutureBuilder<int>(
        future: ApiService().getLikes(widget.id),
        builder: (context, snapshot) {
          final likes = snapshot.data ?? 0;
          return GestureDetector(
            onTap: () async {
              await ApiService().likeCollection(widget.id);
              setState(() {}); // Refresca el FutureBuilder
            },
            child: Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  "$likes likes",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    ],
  ),
),
 */