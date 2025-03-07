import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

class ApiService {
  // Método para iniciar sesión
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
        // Aquí solo retornamos el responseData directamente
        return responseData;
      } else {
        _handleError(response, context);
        return {};
      }
    } catch (e) {
      _showSnackBar(context, 'Error de conexión o datos inválidos: $e');
      throw Exception('Error de conexión o datos inválidos: $e');
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
        showVerificationDialog(context, userId); // Pasar el userId aquí
        return responseData;
      } else {
        _handleError(response, context);
        return {};
      }
    } catch (e) {
      _showSnackBar(context, 'Error de conexión o datos inválidos: $e');
      throw Exception('Error de conexión o datos inválidos: $e');
    }
  }

  void _handleError(http.Response response, BuildContext context) {
    if (response.statusCode == 401) {
      _showSnackBar(context, 'Credenciales inválidas. Verifique sus datos.');
    } else if (response.statusCode == 404) {
      _showSnackBar(context, 'Usuario no encontrado');
    } else if (response.statusCode == 403) {
      _showSnackBar(context, 'Acceso denegado. No tienes permiso.');
    } else {
      _showSnackBar(context,
          'Error del servidor. Código de estado: ${response.statusCode}');
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

  static final encrypt.Key key =
      encrypt.Key.fromUtf8('0123456789abcdef0123456789abcdef'); // 32 caracteres
  static final encrypt.IV iv =
      encrypt.IV.fromLength(16); // Vector de inicialización

  // Método para encriptar la contraseña
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
        _showSnackBar(context, 'Código de verificación incorrecto');
        return {};
      }
    } catch (e) {
      _showSnackBar(context, 'Error al verificar el código: $e');
      throw Exception('Error al verificar el código: $e');
    }
  }

  // Método para mostrar el diálogo de verificación
  Future<void> showVerificationDialog(BuildContext context, int userId) async {
    final TextEditingController _verificationCodeController =
        TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // No permitirá cerrar el diálogo tocando fuera de él
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
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                String code = _verificationCodeController.text;

                if (code.length == 6) {
                  // Aquí puedes verificar si el código es correcto
                  final verifyResponse =
                      await verifyCode(userId, code, context);

                  if (verifyResponse.isNotEmpty) {
                    Navigator.of(context).pop(); // Cerrar el diálogo
                    _showSnackBar(context, 'Código de verificación exitoso');
                    // Proceder con el registro o cualquier otra acción
                  } else {
                    _showErrorSnackbar(
                        context, 'Código inválido. Intente nuevamente.');
                  }
                } else {
                  _showErrorSnackbar(context,
                      'Por favor, ingrese un código válido de 6 dígitos.');
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
