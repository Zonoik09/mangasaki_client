import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mangasaki/views/profileFriend_view.dart';
import 'package:mangasaki/views/profile_view.dart';
import 'package:provider/provider.dart';
import '../connection/api_service.dart';
import '../connection/app_data.dart';
import '../widgets/MangaCollection_widget.dart';
import 'login_view.dart';
import 'main_view.dart';

class DetailsProfileFriendView extends StatefulWidget {
  final String collectionName;
  final int id;
  final String username;
  final int likes;

  DetailsProfileFriendView({
    super.key,
    required this.collectionName,
    required this.id,
    required this.username,
    required this.likes
  });

  @override
  _DetailsProfileFriendViewState createState() =>
      _DetailsProfileFriendViewState();
}

class _DetailsProfileFriendViewState extends State<DetailsProfileFriendView> {
  late Future<List<Map<String, dynamic>>> mangasFuture;
  late Future<Uint8List> imageFuture;

  bool hasLiked = false;

  final Color headerColor = const Color.fromARGB(255, 60, 111, 150);

  @override
  void initState() {
    super.initState();
    mangasFuture = fetchMangas();
    imageFuture = ApiService().getGalleryImage(widget.id);
  }

  void refreshMangaList() {
    setState(() {
      mangasFuture = fetchMangas();
    });
  }

  Future<List<Map<String, dynamic>>> fetchMangas() async {
    List<Map<String, dynamic>> mangasData = [];
    int index = 0;

    Map<String, dynamic> mangaList =
    await ApiService().getMangaGallery(widget.id);
    List resultat = mangaList['resultat'] ?? [];

    List<int> mangaIds =
    resultat.map<int>((item) => item['manga_id'] as int).toList();

    while (index < mangaIds.length) {
      List<int> currentBatch = mangaIds.sublist(
        index,
        (index + 3 <= mangaIds.length) ? index + 3 : mangaIds.length,
      );

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
              MaterialPageRoute(
                builder: (context) => ProfileFriendView(nickname: widget.username,),
              ),
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
                      FutureBuilder<Uint8List>(
                        future: imageFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 150,
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            );
                          } else if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.collectionName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  if (hasLiked) {
                                    //likesCount--;
                                  } else {
                                    //likesCount++;
                                  }
                                  hasLiked = !hasLiked;
                                });

                                if (hasLiked) {
                                  try {
                                    final usuario = await ApiService().getUserInfo(LoginScreen.username);
                                    final fromId = usuario["resultat"]["id"];
                                    sendLikeNotificationViaSocket(
                                      senderUserId: fromId,
                                      receiverUsername: widget.username,
                                      galleryId: widget.id,
                                    );
                                  } catch (e) {
                                    print("Error al enviar notificación de like: $e");
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    hasLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                    hasLiked ? Colors.red : Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${widget.likes} likes",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  final bool isMobile =
                      MediaQuery
                          .of(context)
                          .size
                          .width < 600;

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
                            genres:
                            List<String>.from(manga['genres'] ?? []),
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
                            genres:
                            List<String>.from(manga['genres'] ?? []),
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
    appData.sendMessage(jsonMessage);
  }


}
