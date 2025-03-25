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
    fetchBannerImage(); // Fetch the banner image when the view initializes
  }

  Future<void> fetchBannerImage() async {
    final response = await http.get(Uri.parse("https://mangasaki.ieti.site/api/user/getUserBanner"));

    if (response.statusCode == 200) {
      setState(() {
        // Suponemos que la API devuelve la URL de la imagen del banner en el cuerpo.
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

            // Establece la URL de la imagen de perfil inicial
            profileImageUrl = "https://mangasaki.ieti.site/api/user/getUserImage/$nickname";

            return Container(
              width: contentWidth,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner
                  Container(
                    width: double.infinity,
                    height: 150, // Altura del banner
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
                              height: 150, // Asegurarse de que la imagen cubra el banner
                            ),
                          )
                        : const Center(
                            child: Text(
                              "No Banner Available",
                              style: TextStyle(color: Colors.black54, fontSize: 18),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16), // Espacio entre el banner y el contenido
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.network(
                            // Añadimos el parámetro de marca de tiempo para evitar caché
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
                  ElevatedButton.icon(
                    onPressed: () async {
                      String? base64File = await pickFileAndConvertToBase64();
                      if (base64File != null) {
                        await ApiService().changeProfilePicture(nickname, base64File, context);
                        setState(() {
                          // Aseguramos que la URL de la imagen de perfil se actualice con el parámetro de tiempo
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
