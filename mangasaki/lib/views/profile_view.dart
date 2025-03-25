import 'package:flutter/material.dart';
import 'package:mangasaki/connection/userStorage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../connection/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:http/http.dart' as http;

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? profileImageUrl;
  String? bannerImageUrl;

  @override
  void initState() {
    super.initState();
    fetchBannerImage(); // Se obtiene el banner al iniciar
  }

  Future<void> fetchBannerImage() async {
    final response = await http.get(Uri.parse("https://mangasaki.ieti.site/api/user/getimagebanner"));

    if (response.statusCode == 200) {
      setState(() {
        bannerImageUrl = jsonDecode(response.body)['bannerUrl'];
      });
    } else {
      print("Failed to load banner image");
      setState(() {
        bannerImageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;
    double contentWidth = isDesktop ? screenWidth * 0.6 : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 60, 111, 150),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: UserStorage.getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}\nStackTrace: ${snapshot.stackTrace}",
                  style: const TextStyle(color: Colors.white));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text("No user information found", style: TextStyle(color: Colors.white));
            }

            final userData = snapshot.data!;
            final nickname = userData['resultat']['nickname'] ?? 'User';
            final likes = userData['likes'] ?? 0;

            // Se establece la URL de la imagen de perfil inicial
            profileImageUrl = "https://mangasaki.ieti.site/api/user/getUserImage/$nickname";

            return Container(
              width: contentWidth,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección del banner con botones en la esquina superior derecha
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade300,
                        ),
                        child: bannerImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  bannerImageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "No Banner Available",
                                  style: TextStyle(color: Colors.black54, fontSize: 18),
                                ),
                              ),
                      ),
                      // Botones para cambiar/eliminar banner en la esquina superior derecha
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            // Botón para cambiar el banner
                            ElevatedButton(
                              onPressed: () async {
                                String? base64File = await pickFileAndConvertToBase64();
                                if (base64File != null) {
                                  await ApiService().changeBannerPicture(nickname, base64File, context);
                                  fetchBannerImage(); // Refrescar el banner
                                } else {
                                  print("No se seleccionó ningún archivo.");
                                }
                              },
                              child: const Icon(Icons.upload_file, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.all(10),
                                shape: const CircleBorder(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón para eliminar el banner (solo ícono)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  bannerImageUrl = null;
                                });
                              },
                              child: const Icon(Icons.delete, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.all(10),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Imagen de perfil y datos
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.network(
                            profileImageUrl! + "?${DateTime.now().millisecondsSinceEpoch}",
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            "$likes Likes",
                            style: const TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Botones de acción para la imagen de perfil (abajo de la imagen)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Botón para cambiar la imagen de perfil (igual que en el código que te funcionaba)
                      ElevatedButton.icon(
                        onPressed: () async {
                          String? base64File = await pickFileAndConvertToBase64();
                          if (base64File != null) {
                            await ApiService().changeProfilePicture(nickname, base64File, context);
                            setState(() {
                              profileImageUrl = "https://mangasaki.ieti.site/api/user/getUserImage/$nickname";
                            });
                          } else {
                            print("No se seleccionó ningún archivo.");
                          }
                        },
                        icon: const Icon(Icons.upload_file, color: Colors.white),
                        label: const Text("Change profile image", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón para eliminar la imagen de perfil (solo ícono)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            profileImageUrl = null;
                          });
                        },
                        child: const Icon(Icons.delete, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(10),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Collections",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(color: Colors.white),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: (userData['collections'] as List?)?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              userData['collections']?[index] ?? 'No Data',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Método para convertir archivos a base64
Future<String?> pickFileAndConvertToBase64() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);
    List<int> fileBytes = await file.readAsBytes();
    return base64Encode(fileBytes);
  } else {
    return null;
  }
}

// ApiService con los métodos changeProfilePicture y changeBannerPicture
class ApiService {
  Future<void> changeProfilePicture(String nickname, String base64Image, BuildContext context) async {
    final response = await http.post(
      Uri.parse("https://mangasaki.ieti.site/api/user/changeProfileImage"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nickname': nickname,
        'image': base64Image,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile image updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile image")),
      );
    }
  }

  Future<void> changeBannerPicture(String nickname, String base64Image, BuildContext context) async {
    final response = await http.post(
      Uri.parse("https://mangasaki.ieti.site/api/user/changeBannerImage"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nickname': nickname,
        'image': base64Image,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Banner image updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update banner image")),
      );
    }
  }
}
