import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mangasaki/views/main_view.dart';
import 'package:mangasaki/views/profileFriend_view.dart';
import 'package:provider/provider.dart';
import '../connection/api_service.dart';
import '../connection/app_data.dart';
import '../widgets/MangaCollection_widget.dart';
import 'login_view.dart';

class DetailsProfileFriendView extends StatefulWidget {
  final String collectionName;
  final int galleryId;
  final int likes;
  final String ownerUsername;

  const DetailsProfileFriendView({
    super.key,
    required this.collectionName,
    required this.galleryId,
    required this.likes,
    required this.ownerUsername,
  });

  @override
  State<DetailsProfileFriendView> createState() =>
      _DetailsProfileFriendViewState();
}

class _DetailsProfileFriendViewState extends State<DetailsProfileFriendView> {
  late Future<List<Map<String, dynamic>>> mangasFuture;
  late Future<Uint8List> imageFuture;

  bool hasLiked = false;
  int displayedLikes = 0;

  final Color headerColor = const Color.fromARGB(255, 60, 111, 150);

  @override
  void initState() {
    super.initState();
    mangasFuture = fetchMangas();
    imageFuture = ApiService().getGalleryImage(widget.galleryId);
    displayedLikes = widget.likes;
    checkIfLiked();
  }

  Future<List<Map<String, dynamic>>> fetchMangas() async {
    List<Map<String, dynamic>> mangasData = [];
    int index = 0;

    Map<String, dynamic> mangaList =
        await ApiService().getMangaGallery(widget.galleryId);
    List resultat = mangaList['resultat'] ?? [];

    List<int> mangaIds =
        resultat.map<int>((item) => item['manga_id'] as int).toList();

    while (index < mangaIds.length) {
      List<int> batch = mangaIds.sublist(
          index, (index + 3 <= mangaIds.length) ? index + 3 : mangaIds.length);
      for (var id in batch) {
        var manga = await ApiService().searchManga(id);
        mangasData.add(manga);
      }
      index += 3;
      await Future.delayed(const Duration(seconds: 1));
    }

    return mangasData;
  }

  Future<void> checkIfLiked() async {
    try {
      final userInfo = await ApiService().getUserInfo(LoginScreen.username);
      final userId = userInfo['resultat']['id'];
      final response = await ApiService().isLiked(userId, widget.galleryId);
      setState(() {
        hasLiked = response['liked'] ?? false;
      });
    } catch (e) {
      print("Error checking like status: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: headerColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileFriendView(
                  nickname: widget.ownerUsername,
                ),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: headerColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<Uint8List>(
                    future: imageFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 150,
                          height: 200,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white)),
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
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            if (hasLiked) return;

                            try {
                              final userInfo = await ApiService()
                                  .getUserInfo(LoginScreen.username);
                              final userId = userInfo["resultat"]["id"];

                              sendLikeNotificationViaSocket(
                                senderUserId: userId,
                                receiverUsername: widget.ownerUsername,
                                galleryId: widget.galleryId,
                              );

                              setState(() {
                                hasLiked = true;
                                displayedLikes += 1;
                              });
                            } catch (e) {
                              print("Error sending like: $e");
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                hasLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: hasLiked ? Colors.red : Colors.redAccent,
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
                ],
              ),
            ),
            Container(
              color: headerColor,
              width: double.infinity,
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
                                  genres:
                                      List<String>.from(manga['genres'] ?? []),
                                  type: manga['type'],
                                  id: manga["id"],
                                  galleryName: widget.collectionName,
                                  refreshMangaList:
                                      () {}, // Opcional: sin refresco externo
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
                                  refreshMangaList: () {},
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
}
