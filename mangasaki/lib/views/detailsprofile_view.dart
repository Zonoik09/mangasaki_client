import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mangasaki/connection/api_service.dart';
import 'package:mangasaki/connection/userStorage.dart';
import 'package:mangasaki/views/profile_view.dart';
import 'package:mangasaki/views/top_mangas_view.dart';
import 'package:mangasaki/views/search_view.dart';
import 'package:mangasaki/views/login_view.dart';
import 'package:mangasaki/widgets/widget_home_view.dart';
import 'notification_view.dart';

class DetailsProfileView extends StatefulWidget {
  const DetailsProfileView({Key? key}) : super(key: key);

  @override
  _DetailsProfileViewState createState() => _DetailsProfileViewState();
}

class _DetailsProfileViewState extends State<DetailsProfileView> {
  int _selectedIndex = 1;
  late bool _isMobile;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _principalView(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    _isMobile = screenWidth < 800;

    return Container(
      color: Colors.white,
      child: _isMobile
          ? SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: _buildContent(context),
            )
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Align(
      child: Container(
        width: MediaQuery.of(context).size.width * (_isMobile ? 1 : 0.8),
        constraints: BoxConstraints(
          maxWidth: _isMobile ? double.infinity : MediaQuery.of(context).size.width * 0.8,
          maxHeight: _isMobile ? double.infinity : MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular((_isMobile ? 0 : 15)),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 60, 111, 150),
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Aquí podrías agregar cualquier contenido adicional
            SizedBox(
              height: 20,
            ),
            // Agrega más detalles o configuraciones aquí
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _principalView(context),
      ProfileView(),
      Center(child: Text('Social', style: TextStyle(fontSize: 24, color: Colors.white))),
      TopMangasView(),
      MangaSearchView(),
      Center(child: Text('Themes', style: TextStyle(fontSize: 24, color: Colors.white))),
    ];

    UserStorage.getUserData().then((userData) {
      // Aquí puedes agregar lógica para manejar los datos del usuario
    });

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: UserStorage.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['resultat'] == null) {
                return const Center(child: Text("Error al cargar datos", style: TextStyle(color: Colors.white)));
              }

              // Extraemos los datos del usuario
              final userData = snapshot.data!;
              final nickname = userData['resultat']['nickname'] ?? 'Usuario';
              String profileImageUrl = "https://mangasaki.ieti.site/api/user/getUserImage/$nickname?${DateTime.now().millisecondsSinceEpoch}";

              return Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    color: const Color.fromARGB(255, 60, 111, 150),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.network(
                              profileImageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, color: Colors.white, size: 50);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nickname,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // MENÚ DE OPCIONES
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.home, color: Colors.white),
                          title: const Text('Home', style: TextStyle(color: Colors.white)),
                          onTap: () => _onItemTapped(0),
                        ),
                        ListTile(
                          leading: const Icon(Icons.person, color: Colors.white),
                          title: const Text('Profile', style: TextStyle(color: Colors.white)),
                          onTap: () => _onItemTapped(1),
                        ),
                        ListTile(
                          leading: const Icon(Icons.group, color: Colors.white),
                          title: const Text('Social', style: TextStyle(color: Colors.white)),
                          onTap: () => _onItemTapped(2),
                        ),
                        ListTile(
                          leading: const Icon(Icons.book, color: Colors.white),
                          title: const Text('Top Mangas', style: TextStyle(color: Colors.white)),
                          onTap: () => _onItemTapped(3),
                        ),
                        ListTile(
                          leading: const Icon(Icons.search, color: Colors.white),
                          title: const Text('Search', style: TextStyle(color: Colors.white)),
                          onTap: () => _onItemTapped(4),
                        ),
                        ListTile(
                          leading: const Icon(Icons.color_lens, color: Colors.white),
                          title: const Text('Themes', style: TextStyle(color: Colors.white)),
                          onTap: () => _onItemTapped(5),
                        ),
                      ],
                    ),
                  ),

                  // BOTÓN DE CIERRE DE SESIÓN
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),

      appBar: AppBar(
        title: Center(
          child: Text('MANGASAKI', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Color.fromARGB(255, 60, 111, 150),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationView()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }
}
