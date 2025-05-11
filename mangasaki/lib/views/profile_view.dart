import 'package:flutter/material.dart';
import 'package:mangasaki/connection/userStorage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../connection/api_service.dart';
import '../widgets/ItemCollection_widget.dart';
import 'detailscollections_view.dart';
import 'dart:typed_data';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? profileImageUrl;
  String? bannerImageUrl;
  String? nickname;
  List<Map<String, dynamic>> collections = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchCollections();
  }

  Future<void> fetchUserData() async {
    final userData = await UserStorage.getUserData();
    if (userData != null) {
      setState(() {
        nickname = userData['resultat']['nickname'] ?? 'User';
      });
      fetchBannerImage();
      fetchCollections();
    }
  }

  Future<void> fetchCollections() async {
    if (nickname != null) {
      final galleryData = await ApiService().getGallery(nickname!);
      if (galleryData['resultat'] != null) {
        setState(() {
          collections =
              List<Map<String, dynamic>>.from(galleryData['resultat']);
        });
      }
    }
  }

  Future<void> fetchBannerImage() async {
    if (nickname != null) {
      final response = await http.get(Uri.parse(
          "https://mangasaki.ieti.site/api/user/getUserBanner/$nickname"));
      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('image') ?? false) {
          String base64Image = base64Encode(response.bodyBytes);
          setState(() {
            bannerImageUrl = "data:image/jpeg;base64,$base64Image";
          });
        } else if (response.headers['content-type']
                ?.contains('application/json') ??
            false) {
          try {
            final decodedResponse = jsonDecode(response.body);
            setState(() {
              bannerImageUrl = decodedResponse['bannerUrl'];
            });
          } catch (e) {
            print("Error parsing banner image response: $e");
          }
        }
      } else {
        setState(() {
          bannerImageUrl = null;
        });
      }
    }
  }

  Future<void> changeBannerImage() async {
    String? base64File = await pickFileAndConvertToBase64();
    if (base64File != null && nickname != null) {
      await ApiService().changeBannerPicture(nickname!, base64File, context);
      fetchBannerImage();
    }
  }

  Future<String?> pickFileAndConvertToBase64() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      return base64Encode(fileBytes);
    }
    return null;
  }

  Widget _iconCircleButton(IconData icon, Color borderColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
        side: BorderSide(color: borderColor, width: 2),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: Icon(icon, color: borderColor),
    );
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;

    return Scaffold(
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

                final userData = snapshot.data!;
                final nickname = userData['resultat']['nickname'] ?? 'User';
                final likes = userData['likes'] ?? 0;

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
                                Positioned(
                                  top: 1,
                                  right: 1,
                                  child: Row(
                                    children: [
                                      _iconCircleButton(Icons.upload_file, Colors.green, changeBannerImage),
                                      _iconCircleButton(Icons.delete, Colors.red, () async {
                                        await ApiService().changeBannerPicture(nickname, '', context);
                                        await fetchBannerImage();
                                      },),
                                    ],
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
                            const SizedBox(height: 5), // Space between profile info and buttons
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Change photo button with icon only for mobile
                                _iconCircleButton(Icons.upload_file, Colors.green, () async {
                                  String? base64File = await pickFileAndConvertToBase64();
                                  if (base64File != null) {
                                    await ApiService().changeProfilePicture(nickname, base64File, context);
                                    fetchUserData();
                                  }
                                },),
                                // Delete photo button with icon only for mobile
                                _iconCircleButton(Icons.delete, Colors.red, () async {
                                  await ApiService().changeProfilePicture(nickname, '', context);
                                },),
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
                                const Text("Your Collections",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    String collectionName = '';
                                    bool isButtonEnabled = false;
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              title:
                                                  const Text('New Collection'),
                                              content: TextField(
                                                onChanged: (value) {
                                                  collectionName = value;
                                                  setState(() {
                                                    isButtonEnabled =
                                                        value.trim().isNotEmpty;
                                                  });
                                                },
                                                decoration: const InputDecoration(
                                                    hintText:
                                                        "Enter collection name"),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: isButtonEnabled
                                                      ? () async {
                                                          Navigator.of(context)
                                                              .pop();
                                                          await ApiService()
                                                              .createGallery(
                                                                  nickname,
                                                                  collectionName);
                                                          fetchCollections();
                                                        }
                                                      : null,
                                                  child: const Text('Accept'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
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
                                        future: ApiService()
                                            .getGalleryImage(item["id"]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return const Icon(Icons.error);
                                          } else if (snapshot.hasData) {
                                            return CollectionItemCard(
                                              title:
                                                  item["name"] ?? 'No Title',
                                              imagePath: snapshot.data!,
                                              id: item["id"],
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailsProfileView(
                                                      collectionName:
                                                          item["name"],
                                                      id: item["id"],
                                                    ),
                                                  ),
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
