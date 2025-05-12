import 'package:flutter/material.dart';
import 'package:mangasaki/connection/userStorage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../connection/api_service.dart';
import '../widgets/ItemCollection_widget.dart';
import 'detailscollectionsFriend_view.dart';
import 'dart:typed_data';

import 'login_view.dart';

class ProfileFriendView extends StatefulWidget {
  final String nickname;

  const ProfileFriendView({Key? key, required this.nickname}) : super(key: key);

  @override
  _ProfileFriendViewState createState() => _ProfileFriendViewState();
}

class _ProfileFriendViewState extends State<ProfileFriendView> {
  String? profileImageUrl;
  String? bannerImageUrl;
  List<Map<String, dynamic>> collections = [];

  @override
  void initState() {
    super.initState();
    fetchCollections();
  }

  Future<void> fetchCollections() async {
    final galleryData = await ApiService().getGallery(widget.nickname);
    if (galleryData['resultat'] != null) {
      setState(() {
        collections =
            List<Map<String, dynamic>>.from(galleryData['resultat']);
      });
    }
    }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Friend Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.grey[200],
        body: Center(
          child: SizedBox(
            width: isDesktop ? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 1,
            child: FutureBuilder<Map<String, dynamic>?>(
              future: UserStorage.getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}",
                      style: TextStyle(color: Colors.white));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text("No user information found",
                      style: TextStyle(color: Colors.white));
                }

                final nickname = widget.nickname;
                final likes = 0;

                profileImageUrl =
                    "https://mangasaki.ieti.site/api/user/getUserImage/$nickname";

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === Profile Section ===
                      const Text(
                        "Profile",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Banner
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    height: isDesktop ? 220 : 140,
                                    color: Colors.grey.shade300,
                                    child: bannerImageUrl != null
                                        ? (bannerImageUrl!.startsWith("data:image/")
                                        ? Image.memory(
                                      base64Decode(bannerImageUrl!.split(",")[1]),
                                      fit: BoxFit.cover,
                                    )
                                        : Image.network(
                                      bannerImageUrl!,
                                      fit: BoxFit.cover,
                                    ))
                                        : const Center(child: Text("No Banner Available")),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Profile Info
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[300],
                                  child: ClipOval(
                                    child: Image.network(
                                      "$profileImageUrl?${DateTime.now().millisecondsSinceEpoch}",
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Nickname & Likes
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nickname,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.pink.shade50,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.favorite, color: Colors.pink, size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              "$likes",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.pink,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // === Collections Section ===
                      const Text(
                        "Collections",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header + botón
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Collections of $nickname",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 10),

                            // Grid
                            collections.isEmpty
                                ? const Center(
                                    child:
                                        Text('No hay colecciones disponibles.'))
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: collections.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 400,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: 0.7,
                                    ),
                                    itemBuilder: (context, index) {
                                      final item = collections[index];
                                      return FutureBuilder<Uint8List>(
                                        future: ApiService().getGalleryImage(item["id"]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return const Icon(Icons.error);
                                          } else if (snapshot.hasData) {
                                            return FutureBuilder<Map<String, dynamic>>(
                                              future: ApiService().getUserInfo(LoginScreen.username),
                                              builder: (context, userSnapshot) {
                                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                  return const CircularProgressIndicator();
                                                } else if (userSnapshot.hasError || !userSnapshot.hasData) {
                                                  return const Icon(Icons.error);
                                                }
                                                final fromId = userSnapshot.data!["resultat"]["id"];
                                                return CollectionItemCard(
                                                  title: item["name"] ?? 'No Title',
                                                  imagePath: snapshot.data!,
                                                  id: item["id"],
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => DetailsProfileFriendView(
                                                          collectionName: item["name"],
                                                          id: item["id"],
                                                          userId: fromId,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          } else {
                                            return const Icon(Icons.error);
                                          }
                                        },
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        )
    );
  }
}
