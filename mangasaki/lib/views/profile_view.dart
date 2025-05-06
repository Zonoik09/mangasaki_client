import 'package:flutter/material.dart';
import 'package:mangasaki/connection/userStorage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../connection/api_service.dart';
import '../widgets/ItemCollection_widget.dart';
import 'detailscollections_view.dart';

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
      fetchCollections(); // Agrega esta línea
    }
  }

  Future<void> fetchCollections() async {
    if (nickname != null) {
      final galleryData = await ApiService().getGallery(nickname!);
      if (galleryData['resultat'] != null) {
        setState(() {
          collections =
          List<Map<String, dynamic>>.from(galleryData['resultat']);
          print("Colecciones cargadas: $collections");  // <-- DEBUG

        });
      }
    }
  }

  Future<void> fetchBannerImage() async {
    if (nickname != null) {
      final response = await http.get(Uri.parse(
          "https://mangasaki.ieti.site/api/user/getUserBanner/$nickname"));

      print("Response Content-Type: ${response.headers['content-type']}");

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('image') ?? false) {
          print("Received an image response");

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
        } else {
          print("Unexpected content type: ${response.headers['content-type']}");
        }
      } else {
        print(
            "Failed to load banner image. Status code: ${response.statusCode}");
        setState(() {
          bannerImageUrl = null;
        });
      }
    }
  }

  Future<void> changeBannerPicture(
      String nickname, String base64File, BuildContext context) async {
    final Uri url = Uri.parse(
        "https://mangasaki.ieti.site/api/user/changeUserProfileBanner");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': nickname,
          'base64': base64File,
        }),
      );

      print("Change Banner Response: ${response.body}");

      if (response.statusCode == 200) {
        String responseBody = response.body;
        if (responseBody.contains("Banner updated successfully")) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Banner updated successfully")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Unexpected response: $responseBody")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Failed to update banner. Status: ${response.statusCode}")));
      }
    } catch (e) {
      print("Error occurred while changing banner: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> changeBannerImage() async {
    String? base64File = await pickFileAndConvertToBase64();
    if (base64File != null && nickname != null) {
      await ApiService().changeBannerPicture(nickname!, base64File, context);
      fetchBannerImage();
    } else {
      print("No se seleccionó ningún archivo.");
    }
  }

  Future<String?> pickFileAndConvertToBase64() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      String base64String = base64Encode(fileBytes);
      return base64String;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;
    double contentWidth = isDesktop ? screenWidth * 0.6 : screenWidth;

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        body: Center(
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
                  child: Container(
                    width: contentWidth,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: isDesktop ? 200 : 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade300,
                              ),
                              child: bannerImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: bannerImageUrl!
                                              .startsWith("data:image/")
                                          ? Image.memory(
                                              base64Decode(bannerImageUrl!
                                                  .split(",")[1]),
                                              fit: BoxFit.cover)
                                          : Image.network(bannerImageUrl!,
                                              fit: BoxFit.cover),
                                    )
                                  : const Center(
                                      child: Text(
                                        "No Banner Available",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 18),
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: changeBannerImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.all(10),
                                      shape: const CircleBorder(),
                                    ),
                                    child: const Icon(Icons.upload_file,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        ApiService().changeBannerPicture(
                                            nickname!, '', context);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.all(10),
                                      shape: const CircleBorder(),
                                    ),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Perfil
                        isDesktop
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Perfil + Info
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.transparent,
                                        child: ClipOval(
                                          child: Image.network(
                                            "${profileImageUrl!}?${DateTime.now().millisecondsSinceEpoch}",
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nickname,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.05,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "Likes: $likes",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Botones desktop
                                  Column(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          String? base64File =
                                              await pickFileAndConvertToBase64();
                                          if (base64File != null) {
                                            await ApiService()
                                                .changeProfilePicture(nickname,
                                                    base64File, context);
                                            setState(() {
                                              profileImageUrl =
                                                  "https://mangasaki.ieti.site/api/user/getUserImage/$nickname";
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.upload_file,
                                            color: Colors.white),
                                        label: const Text(
                                            "Change Profile Image",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await ApiService()
                                              .changeProfilePicture(
                                                  nickname, '', context);
                                          setState(() {
                                            profileImageUrl = "";
                                          });
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.white),
                                        label: const Text(
                                            "Delete Profile Image",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Colors.transparent,
                                            child: ClipOval(
                                              child: Image.network(
                                                "${profileImageUrl!}?${DateTime.now().millisecondsSinceEpoch}",
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[700],
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.upload_file,
                                                      color: Colors.white,
                                                      size: 18),
                                                  onPressed: () async {
                                                    String? base64File =
                                                        await pickFileAndConvertToBase64();
                                                    if (base64File != null) {
                                                      await ApiService()
                                                          .changeProfilePicture(
                                                              nickname,
                                                              base64File,
                                                              context);
                                                      setState(() {
                                                        profileImageUrl =
                                                            "https://mangasaki.ieti.site/api/user/getUserImage/$nickname";
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red[600],
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color: Colors.white,
                                                      size: 18),
                                                  onPressed: () async {
                                                    await ApiService()
                                                        .changeProfilePicture(
                                                            nickname,
                                                            '',
                                                            context);
                                                    setState(() {
                                                      profileImageUrl = "";
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nickname,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.05,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "Likes: $likes",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                        const SizedBox(height: 50),

                        // Título de Collections y botón +
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Collections",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add,
                                    size: 18, color: Colors.black),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String collectionName = '';
                                      bool isButtonEnabled = false;
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('New Collection'),
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
                                                    "Enter collection name",
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
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
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white, thickness: 2.5),
                        const SizedBox(height: 10),

                        // Grid de colecciones
                        collections.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay colecciones disponibles.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
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
                                  return CollectionItemCard(
                                      title: item["name"] ?? 'Sin título',
                                      imagePath: item["image_url"] ?? '',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailsProfileView(
                                            collectionName: item["name"],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                );
              }),
        ));
  }
}
