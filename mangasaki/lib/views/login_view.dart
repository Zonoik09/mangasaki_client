import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoginView = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromFile();
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

    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            // Sección del GIF (75% del ancho)
            SizedBox(
              width: screenWidth * 0.75,
              height: screenHeight,
              child: Image.asset(
                'assets/images/background2.gif',
                fit: BoxFit.cover,
              ),
            ),

            // Sección del Login/Registro (25% del ancho)
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
                        height: MediaQuery.of(context).size.height / 4,
                        child: Image.asset('assets/images/logo.png')),

                    const SizedBox(height: 150),
                    // Sección de Login o Registro
                    if (_isLoginView) ...[
                      _buildLoginFields(),
                    ] else ...[
                      _buildRegisterFields(),
                    ],

                    const SizedBox(height: 35),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          if (_isLoginView) {
                            if (_usernameController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Todos los campos son obligatorios.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          } else {
                            if (_usernameController.text.isEmpty ||
                                _phoneController.text.isEmpty ||
                                _passwordController.text.isEmpty ||
                                _confirmPasswordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Todos los campos son obligatorios.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Las contraseñas no coinciden.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          }
                        },
                        child: Container(
                          width: screenWidth * 0.15,
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
                      ),
                    ),
                    if (_isLoginView) const SizedBox(height: 350),
                    if (!_isLoginView) const SizedBox(height: 220),
                    // Enlace para cambiar entre Login y Register
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLoginView = !_isLoginView;
                        });
                      },
                      child: Center(
                        // Centra el texto dentro del GestureDetector
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
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFields() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: TextField(
            controller: _usernameController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: 'USERNAME OR PHONE',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'PASSWORD',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterFields() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: TextField(
            controller: _usernameController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: 'USERNAME',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: TextField(
            controller: _phoneController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.phone,
                color: Colors.white,
              ),
              hintText: 'PHONE',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'PASSWORD',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'CONFIRM PASSWORD',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
