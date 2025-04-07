import 'package:flutter/material.dart';
import 'package:mangasaki/connection/userStorage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../connection/api_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? profileImageUrl;
  String? bannerImageUrl;
  String? nickname; // Guardamos el nickname del usuario

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final userData = await UserStorage.getUserData();
    if (userData != null) {
      setState(() {
        nickname = userData['resultat']['nickname'] ?? 'User';
      });
      fetchBannerImage();
    }
  }

  Future<void> fetchBannerImage() async {
    if (nickname != null) {
      final response = await http.get(Uri.parse("https://mangasaki.ieti.site/api/user/getUserBanner/$nickname"));

      // Imprimir el tipo de contenido para depuración
      print("Response Content-Type: ${response.headers['content-type']}");

      if (response.statusCode == 200) {
        // Verificamos si la respuesta es una imagen
        if (response.headers['content-type']?.contains('image') ?? false) {
          print("Received an image response");
          
          // Convertir la respuesta de la imagen en formato base64
          String base64Image = base64Encode(response.bodyBytes);
          
          setState(() {
            // Asumimos que aquí se puede establecer la URL de la imagen o base64 para mostrarla en la UI
            bannerImageUrl = "data:image/jpeg;base64,$base64Image";
          });
        } else if (response.headers['content-type']?.contains('application/json') ?? false) {
          // Si la respuesta es JSON, analizarla
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
        print("Failed to load banner image. Status code: ${response.statusCode}");
        setState(() {
          bannerImageUrl = null;
        });
      }
    }
  }

  Future<void> changeBannerPicture(String nickname, String base64File, BuildContext context) async {
    final Uri url = Uri.parse("https://mangasaki.ieti.site/api/user/changeUserProfileBanner");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': nickname,
          'base64': base64File,
        }),
      );

      print("Change Banner Response: ${response.body}");  // Imprimir respuesta para depuración

      if (response.statusCode == 200) {
        String responseBody = response.body;
        if (responseBody.contains("Banner updated successfully")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Banner updated successfully"))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unexpected response: $responseBody"))
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update banner. Status: ${response.statusCode}"))
        );
      }
    } catch (e) {
      print("Error occurred while changing banner: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );
    }
  }

  Future<void> changeBannerImage() async {
    String? base64File = await pickFileAndConvertToBase64();
    if (base64File != null && nickname != null) {
      await ApiService().changeBannerPicture(nickname!, base64File, context);
      fetchBannerImage(); // Refrescar el banner
    } else {
      print("No se seleccionó ningún archivo.");
    }
  }

  Future<String?> pickFileAndConvertToBase64() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

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
                  // Banner con botones
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
                                child: bannerImageUrl!.startsWith("data:image/")
                                    ? Image.memory(base64Decode(bannerImageUrl!.split(",")[1]), fit: BoxFit.cover)
                                    : Image.network(bannerImageUrl!, fit: BoxFit.cover),
                              )
                            : const Center(
                                child: Text(
                                  "No Banner Available",
                                  style: TextStyle(color: Colors.black54, fontSize: 18),
                                ),
                              ),
                      ),
                      // Botones en la esquina superior derecha
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: changeBannerImage,
                              child: const Icon(Icons.upload_file, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.all(10),
                                shape: const CircleBorder(),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                  
                  // Botón para cambiar la imagen de perfil
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
                  const SizedBox(height: 20),
                  
                  // Canvas para mostrar los rectángulos
                  CustomPaint(
                    size: Size(double.infinity, 200),  // Tamaño del canvas
                    painter: RectanglesPainter(),
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

class RectanglesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, 60, 111, 150)  // Fondo azul
      ..style = PaintingStyle.fill;

    Paint borderPaint = Paint()
      ..color = Colors.white  // Color blanco para los bordes
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;  // Grosor del borde

    double rectWidth = size.width / 3;  // Tres rectángulos por fila
    double rectHeight = 140;
    
    // Lista de nombres y imágenes
    List<String> names = ['Name 1', 'Name 2', 'Name 3', 'Name 4', 'Name 5'];
    List<String> imagePaths = [
      'assets/image1.png', 'assets/image2.png', 'assets/image3.png', 'assets/image4.png', 'assets/image5.png'
    ];

    // Dibujar rectángulos en columnas
    for (int i = 0; i < names.length; i++) {
      double x = (i % 1) * rectWidth;  // Solo una columna por fila
      double y = (i ~/ 1) * (rectHeight + 10);  // Nueva fila cada rectángulo

      // Crear un rectángulo con bordes redondeados
      Rect rect = Rect.fromLTWH(x, y, rectWidth, rectHeight);
      RRect roundedRect = RRect.fromRectAndRadius(rect, Radius.circular(15));

      // Dibujar el rectángulo con borde
      canvas.drawRRect(roundedRect, paint);
      canvas.drawRRect(roundedRect, borderPaint);

      // Pintar el texto (nombre) en la parte superior del rectángulo
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: names[i],
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (rectWidth - textPainter.width) / 2, y + 10));

      // Pintar la imagen (centrada dentro del rectángulo)
      // Aquí utilizamos la imagen como un widget, pero en un CustomPainter no se puede utilizar directamente un widget
      // Para dibujar imágenes debes cargar las imágenes como `ImageProvider` o usar el método `canvas.drawImage`
      // Aquí simulamos el uso de una imagen centrada
      Image image = Image.asset(imagePaths[i]);  // Cargar la imagen desde assets
      double imageWidth = 50;  // Ajusta el tamaño de la imagen
      double imageHeight = 50;

      // Simulamos que la imagen estaría centrada
      image.image.resolve(ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo image, bool synchronousCall) {
          canvas.drawImage(image.image, Offset(x + (rectWidth - imageWidth) / 2, y + (rectHeight - imageHeight) / 2), Paint());
        })
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
