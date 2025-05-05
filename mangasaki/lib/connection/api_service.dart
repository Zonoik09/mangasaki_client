import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart'; // Para seleccionar archivos
import 'package:mangasaki/connection/utils_websockets.dart';

import '../views/main_view.dart';

class ApiService {

  // Metodo para iniciar sesión
  Future<Map<String, dynamic>> login(
      String username, String pass, BuildContext context) async {
    final url = Uri.parse('https://mangasaki.ieti.site/api/user/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': username,
          'password': pass,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        _handleError(response, context);
        return {};
      }
    } catch (e) {
      _showSnackBar(context, 'Connection error or invalid data: $e');
      throw Exception('Connection error or invalid data: $e');
    }
  }

  // Metodo para register
  Future<Map<String, dynamic>> register(String username, String pass,
      String pass2, String phone, BuildContext context) async {
    final url = Uri.parse('https://mangasaki.ieti.site/api/user/register');

    if (pass != pass2) {
      _showSnackBar(context, "The passwords are not the same");
      throw Exception("Las contraseñas no coinciden");
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': username,
          'password': pass,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userId = responseData['data']['userId'];

        // Una vez registrado, mostramos el diálogo de verificación
        showVerificationDialog(context, userId);
        return responseData;

      } else {
        _handleError(response, context);
        return {};
      }
    } catch (e) {
      _showSnackBar(context, 'Connection error or invalid data: $e');
      throw Exception('Connection error or invalid data: $e');
    }
  }

  // Metodo para analizar el manga
  Future<Map<String, dynamic>> analyzeManga(String base64Image) async {
    final url = Uri.parse('https://mangasaki.ieti.site/api/manga/analyzeManga');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'base64Image': base64Image,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Llamada a la api de verificación de codigo.
  Future<Map<String, dynamic>> verifyCode(
      int userId, String code, BuildContext context) async {
    final url = Uri.parse('https://mangasaki.ieti.site/api/user/validate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId.toString(),
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _showSnackBar(context, 'Incorrect verification code.');
        return {};
      }
    } catch (e) {
      _showSnackBar(context, 'Error verifying the code: $e');
      throw Exception('Error verifying the code: $e');
    }
  }

  // Obtener información del usuario
  Future<Map<String, dynamic>> getUserInfo(String nickname) async {
    final url = Uri.parse('https://mangasaki.ieti.site/api/user/getUserInfo/$nickname');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener la información del usuario: ${response.statusCode}');
    }
  }

  // Obtener los mangas más populares
  Future<List<dynamic>> getTopMangas() async {
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/top/manga?limit=24'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load top mangas');
    }
  }

  // Cambiar imagen de perfil
  Future<Map<String, dynamic>> changeProfilePicture(String username, String image, BuildContext context) async {
    final url = Uri.parse('https://mangasaki.ieti.site/api/user/changeUserProfileImage');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': username,
          'base64': image,
        }),
      );

      if (response.statusCode == 200) {
        print("Se ha subido la imagen con éxito");
        return jsonDecode(response.body);
      } else {
        _showSnackBar(context, 'Error uploading the image');
        throw Exception("Error");
      }

    } catch (e) {
      _showSnackBar(context, 'Error uploading the image $e');
      throw Exception('Error verifying the code: $e');
    }
  }

  // Cambiar imagen del banner
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Banner updated successfully"))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update banner"))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );
    }
  }

  // Método para seleccionar un archivo y convertirlo a base64
  Future<String?> pickFileAndConvertToBase64() async {
    // Abre un cuadro de diálogo para seleccionar el archivo
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Lee el archivo seleccionado
      Uint8List fileBytes = result.files.single.bytes!;
      // Convierte el archivo en una cadena base64
      return base64Encode(fileBytes);
    }
    return null;
  }

  // Mostrar el cuadro de verificación
  Future<void> showVerificationDialog(BuildContext context, int userId) async {
    final TextEditingController _verificationCodeController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enter Verification Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _verificationCodeController,
                decoration: const InputDecoration(
                  hintText: 'Enter 6-digit code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                String code = _verificationCodeController.text;

                if (code.length == 6) {
                  final verifyResponse = await verifyCode(userId, code, context);

                  if (verifyResponse.isNotEmpty) {
                    Navigator.of(dialogContext).pop();

                    _showSnackPositiveBar(context, 'Successful verification code');

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainView()),
                    );
                  } else {
                    _showErrorSnackbar(
                        dialogContext, 'Invalid code. Please try again.');
                  }
                } else {
                  _showErrorSnackbar(dialogContext,
                      'Please enter a valid 6-digit code.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Métodos de manejo de errores y notificaciones
  void _handleError(http.Response response, BuildContext context) {
    if (response.statusCode == 401) {
      _showSnackBar(context, 'Invalid credentials. Please check your details.');
    } else if (response.statusCode == 404) {
      _showSnackBar(context, 'User not found.');
    } else if (response.statusCode == 403) {
      _showSnackBar(context, 'Access denied. You do not have permission.');
    } else {
      _showSnackBar(context,
          'Server error. Status code: ${response.statusCode}');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSnackPositiveBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  static final encrypt.Key key =
  encrypt.Key.fromUtf8('0123456789abcdef0123456789abcdef'); // 32 caracteres
  static final encrypt.IV iv =
  encrypt.IV.fromLength(16); // Vector de inicialización

  // Metodo para encriptar la contraseña
  String _encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  // Corregir la función _showErrorSnackbar pasando el context correctamente
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Obtener información del usuario
  Future<Map<String, dynamic>> getUsersFriends(String letters) async {
    final url = Uri.parse('https://mangasaki.ieti.site/api/user/search/$letters');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener la información del usuario: ${response.statusCode}');
    }
  }

  // Obtener información del usuario
  Future<Uint8List> getUserImage(String username) async {
    final url = Uri.parse('https://mangasaki.ieti.site/api/user/getUserImage/$username');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.bodyBytes; // Obtenemos los bytes de la imagen
    } else {
      throw Exception('Error al obtener la imagen del usuario');
    }
  }
}
