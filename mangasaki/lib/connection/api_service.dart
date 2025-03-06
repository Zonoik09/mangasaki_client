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

// Método para Registrarse
  Future<Map<String, dynamic>> register(String username, String pass,
      String pass2, int phone, BuildContext context) async {
    final url = Uri.parse('https://mangasaki.ieti.site/api/user/register');

    if (pass != pass2) {
      _showSnackBar(context, "The passwords are not the same");
      throw Exception("Las contraseñas no coinciden");
    }

    // Encriptar la contraseña antes de enviarla
    //String encryptedPass = _encryptPassword(pass);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': username,
          //'password': encryptedPass,
          'passoword': pass,
          'phone': phone,
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
}
