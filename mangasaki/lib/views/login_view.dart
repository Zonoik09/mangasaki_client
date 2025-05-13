import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../connection/api_service.dart';
import '../connection/app_data.dart';
import '../connection/userStorage.dart';
import 'main_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  static String username = "";
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();



  bool _isLoginView = true;
  late bool _isMobile;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadDataFromFile() async {
    try {
      const path = 'data/';
      final file = File('$path/data.json');

      if (file.existsSync()) {
        final String content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);

        if (data.containsKey('ServerKey') && data.containsKey('UsernameKey')) {
          _usernameController.text = data['UsernameKey'];
        }
      }
    } catch (e) {
      print('Error al cargar los datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    _isMobile =
        screenWidth < 800; // Se considera móvil si el ancho es menor a 800px

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Fondo GIF
            Positioned.fill(
              child: Image.asset(
                'assets/images/background2.gif',
                fit: BoxFit.cover,
              ),
            ),
            _isMobile
                ? _buildMobileLayout(screenWidth, screenHeight)
                : _buildDesktopLayout(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double screenWidth, double screenHeight) {
    return Center(
      child: Container(
        width: screenWidth * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: screenWidth * 0.5,
              height: 100,
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(height: 20),
            if (_isLoginView) _buildLoginFields() else _buildRegisterFields(),
            const SizedBox(height: 20),
            _buildActionButton(screenWidth),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLoginView = !_isLoginView;
                });
              },
              child: Text(
                _isLoginView
                    ? 'New here? Sign up now!'
                    : 'Already have an account? Log in here!',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Color.fromARGB(255, 60, 111, 150),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(double screenWidth, double screenHeight) {
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.75,
          height: screenHeight,
          child: Image.asset(
            'assets/images/background2.gif',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          width: screenWidth * 0.25,
          height: screenHeight,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                    width: double.infinity,
                    height: screenHeight / 4,
                    child: Image.asset('assets/images/logo.png')),
                const SizedBox(height: 70),
                if (_isLoginView)
                  _buildLoginFields()
                else
                  _buildRegisterFields(),
                const SizedBox(height: 35),
                Center(child: _buildActionButton(screenWidth)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLoginView = !_isLoginView;
                    });
                  },
                  child: Center(
                    child: Text(
                      _isLoginView
                          ? 'New here? Sign up now!'
                          : 'Already have an account? Log in here!',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Color.fromARGB(255, 60, 111, 150),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(double screenWidth) {
    return GestureDetector(
      onTap: () async {
        if (_isLoginView) {
          // Validación para login
          if (_usernameController.text.isEmpty ||
              _passwordController.text.isEmpty) {
            _showErrorSnackbar('All fields are required.');
            return;
          }

          // Llamada al login
          final loginResponse = await ApiService().login(
            _usernameController.text,
            _passwordController.text,
            context,
          );

          if (loginResponse['status'] == 'OK') {
            // Navegar a la pantalla MainView
            try {
              final userInfo = await ApiService().getUserInfo(_usernameController.text);
              print("Nombre de usuario: $userInfo");
              await UserStorage.saveUserData(userInfo);
              LoginScreen.username = _usernameController.text;
              // Obtener la instancia de AppData
              final appData = Provider.of<AppData>(context, listen: false);
              // Intentar establecer la conexión WebSocket
              appData.connectToWebSocket();
              AppData.disconnectedForUser = false;
            } catch (e) {
              print('Error al obtener y guardar la información del usuario: $e');
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainView()),
            );
          } else {
            _showErrorSnackbar('Login error. Please check your credentials.');
          }

        } else {
          // Para el caso de registro
          if (_usernameController.text.isEmpty ||
              _phoneController.text.isEmpty ||
              _passwordController.text.isEmpty ||
              _confirmPasswordController.text.isEmpty) {
            _showErrorSnackbar('All fields are required.');
            return;
          }

          if (_passwordController.text.length < 8 ||
              !_passwordController.text.contains(RegExp(r'[a-z]')) ||
              !_passwordController.text.contains(RegExp(r'[A-Z]')) ||
              !_passwordController.text.contains(RegExp(r'\d'))) {
            _showErrorSnackbar('The password is not secure. It must contain at least one uppercase letter, one lowercase letter, one number, and be at least 8 characters long.');
            return;
          }

          if (_passwordController.text != _confirmPasswordController.text) {
            _showErrorSnackbar('The passwords do not match.');
            return;
          }

          // Llamada al register (asumirás que tienes el ApiService importado)
          final registerResponse = await ApiService().register(
            _usernameController.text,
            _passwordController.text,
            _confirmPasswordController.text,
            _phoneController.text,
            context,
          );
          if (registerResponse['status'] == 'OK') {
            try {
              final userInfo = await ApiService().getUserInfo(_usernameController.text);
              await UserStorage.saveUserData(userInfo);
            } catch (e) {
              print('Error al obtener y guardar la información del usuario: $e');
            }
          } else {
            _showErrorSnackbar('Registration error. Please try again.');
          }
        }
      },
      child: Container(
        width: _isMobile ? screenWidth * 0.6 : screenWidth * 0.15,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Color.fromARGB(255, 60, 111, 150),
        ),
        child: Center(
          child: Text(
            _isLoginView ? 'LOGIN' : 'REGISTER',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
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

  Widget _buildLoginFields() {
    return Column(
      children: [
        _buildTextField(_usernameController, 'USERNAME', Icons.person),
        const SizedBox(height: 15),
        _buildTextField(_passwordController, 'PASSWORD', Icons.lock,
            isPassword: true),
      ],
    );
  }

  Widget _buildRegisterFields() {
    return Column(
      children: [
        _buildTextField(_usernameController, 'USERNAME', Icons.person),
        const SizedBox(height: 15),
        _buildTextField(_phoneController, 'PHONE', Icons.phone),
        const SizedBox(height: 15),
        _buildTextField(_passwordController, 'PASSWORD', Icons.lock,
            isPassword: true),
        const SizedBox(height: 15),
        _buildTextField(
            _confirmPasswordController, 'CONFIRM PASSWORD', Icons.lock,
            isPassword: true),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white),
          contentPadding: const EdgeInsets.symmetric(vertical: 16), // Centra el texto
        ),
      ),
    );
  }

}
