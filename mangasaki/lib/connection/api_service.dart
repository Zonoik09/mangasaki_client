import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

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
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        _showSnackBar(context, 'Incorrect verification code.');
        return {};
      }
    } catch (e) {
      _showSnackBar(context, 'Error verifying the code: $e');
      throw Exception('Error verifying the code: $e');
    }
  }

  // Metodo para mostrar el diálogo de verificación
  Future<void> showVerificationDialog(BuildContext context, int userId) async {
    final TextEditingController _verificationCodeController =
        TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible:
          false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Verification Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _verificationCodeController,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6, // Limitar la longitud a 6
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                String code = _verificationCodeController.text;

                if (code.length == 6) {
                  final verifyResponse =
                      await verifyCode(userId, code, context);

                  if (verifyResponse.isNotEmpty) {
                    Navigator.of(context).pop();
                    _showSnackPositiveBar(context, 'Successful verification code');
                  } else {
                    _showErrorSnackbar(
                        context, 'Invalid code. Please try again.');
                  }
                } else {
                  _showErrorSnackbar(context,
                      'Please enter a valid 6-digit code.');
                }
              },
            ),
          ],
        );
      },
    );
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
}
