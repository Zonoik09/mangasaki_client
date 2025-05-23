import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mangasaki/views/profile_view.dart';
import 'package:provider/provider.dart';
import '../connection/api_service.dart';
import '../connection/app_data.dart';
import '../widgets/MangaCollection_widget.dart';
import 'dart:typed_data';

import 'login_view.dart';
import 'main_view.dart';

class DetailsProfileView extends StatefulWidget {
  final String collectionName;
  final int id;
  final int likes;

  const DetailsProfileView({super.key, required this.collectionName, required this.id, required this.likes});

  @override
  _DetailsProfileViewState createState() => _DetailsProfileViewState();
}

class _DetailsProfileViewState extends State<DetailsProfileView> {
  late Future<List<Map<String, dynamic>>> mangasFuture;
  late Future<Uint8List> imageFuture;

  bool hasLiked = false;
  int displayedLikes = 0;

  final Color headerColor = const Color.fromARGB(255, 60, 111, 150);
  final List<int> mangaList = [];

  @override
  void initState() {
    super.initState();
    mangasFuture = fetchMangas();
    imageFuture = ApiService().getGalleryImage(widget.id);
    displayedLikes = widget.likes;
    checkIfLiked();
  }

  void refreshMangaList() {
    setState(() {
      mangasFuture = fetchMangas();
    });
  }

  Future<List<Map<String, dynamic>>> fetchMangas() async {
    List<Map<String, dynamic>> mangasData = [];
    int index = 0;

    Map<String, dynamic> mangaList = await ApiService().getMangaGallery(widget.id);
    List resultat = mangaList['resultat'] ?? [];

    List<int> mangaIds = resultat.map<int>((item) => item['manga_id'] as int).toList();

    while (index < mangaIds.length) {
      List<int> currentBatch = mangaIds.sublist(index,
          (index + 3 <= mangaIds.length) ? index + 3 : mangaIds.length);

      for (int mangaid in currentBatch) {
        var manga = await ApiService().searchManga(mangaid);
        mangasData.add(manga);
      }

      index += 3;
      await Future.delayed(const Duration(seconds: 1));
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
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainView(selectedIndex: 1)),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                                      checkIfLiked();
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
                                widget.collectionName,
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
                            GestureDetector(
                              onTap: () async {
                                if (hasLiked) return;

                                try {
                                  final usuario = await ApiService().getUserInfo(LoginScreen.username);
                                  final fromId = usuario["resultat"]["id"];
                                  sendLikeNotificationViaSocket(
                                    senderUserId: fromId,
                                    receiverUsername: LoginScreen.username,
                                    galleryId: widget.id,
                                  );

                                  setState(() {
                                    hasLiked = true;
                                    displayedLikes += 1;
                                  });
                                } catch (e) {
                                  print("Error al enviar notificación de like: $e");
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    hasLiked ? Icons.favorite : Icons.favorite_border,
                                    color: hasLiked ? Colors.red : Colors.redAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$displayedLikes likes",
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
                            genres: List<String>.from(manga['genres'] ?? []),
                            type: manga['type'],
                            id: manga["id"],
                            galleryName: widget.collectionName,
                            refreshMangaList: refreshMangaList,
                          )
                              : MangaCollectionWidget(
                            title: manga['title'],
                            imageUrl: manga['imageUrl'],
                            status: manga['status'],
                            score: manga['score'],
                            rank: manga['rank'],
                            description: manga['description'],
                            chapters: manga['chapters'],
                            genres: List<String>.from(manga['genres'] ?? []),
                            type: manga['type'],
                            id: manga["id"],
                            galleryName: widget.collectionName,
                            refreshMangaList: refreshMangaList,
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

  void sendLikeNotificationViaSocket({
    required int senderUserId,
    required String receiverUsername,
    required int galleryId,
  }) {
    final message = {
      'type': 'like_notification',
      'sender_user_id': senderUserId,
      'receiver_username': receiverUsername,
      'gallery_id': galleryId,
    };
    final jsonMessage = jsonEncode(message);
    final appData = Provider.of<AppData>(context, listen: false);
    appData.onNotificationSent = (message) {
      if (!mounted) return;
      final snackBar = SnackBar(content: Text(message), backgroundColor: Colors.green,);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    };
    appData.sendMessage(jsonMessage);
  }

  Future<void> checkIfLiked() async {
    try {
      final usuario = await ApiService().getUserInfo(LoginScreen.username);
      final fromId = usuario["resultat"]["id"];

      final response = await ApiService().isLiked(fromId, widget.id);
      setState(() {
        hasLiked = response["liked"] ?? false;
      });
    } catch (e) {
      print("Error verificando si dio like: $e");
    }
  }
}
