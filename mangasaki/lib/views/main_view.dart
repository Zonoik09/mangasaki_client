import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mangasaki/connection/api_service.dart';
import 'package:mangasaki/views/profile_view.dart';
import 'package:mangasaki/views/search_view.dart';
import 'package:mangasaki/views/social_view.dart';
import 'package:mangasaki/views/top_mangas_view.dart';
import 'package:mangasaki/widgets/widget_home_view.dart';
import 'package:mangasaki/views/login_view.dart';
import 'package:provider/provider.dart';

import '../connection/NotificationRepository.dart';
import '../connection/app_data.dart';
import '../connection/userStorage.dart';
import 'camera_screen.dart';
import 'notification_view.dart';

class MainView extends StatefulWidget {
  final int selectedIndex;

  const MainView({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}


class _MainViewState extends State<MainView> {
  late int _selectedIndex;
  late bool _isMobile;
  List<Map<String, dynamic>> friendRequests = [];
  int pendingNotifications = 0;
  Timer? _timer;
  int? userId;

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el Timer cuando el widget se elimina
    super.dispose();
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadNotifications() async {
    try {
      final userData = await UserStorage.getUserData();
      final currentUserId = userData?['resultat']['id'];

      if (currentUserId == null) return;

      final notifications = await ApiService().getNotifications(currentUserId);
      final List<dynamic> data = notifications['data'];
      final int newCount = data.length;

      // Solo actualiza si hay un cambio real
      if (mounted &&
          (newCount != pendingNotifications || currentUserId != userId)) {
        setState(() {
          userId = currentUserId;
          friendRequests = List<Map<String, dynamic>>.from(data);
          pendingNotifications = newCount;
        });
      }
    } catch (e) {
      print("Error al cargar notificaciones: $e");
    }
  }



  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;

    // Ejecutar después del primer frame, sin bloquear construcción inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications(); // primera carga, no bloquea el build
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        _loadNotifications(); // sigue ejecutándose sin afectar UI
      });
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
            // Primera sección (título y subtítulo)
            SizedBox(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = MediaQuery.of(context).size.width;
                  bool isMobile = screenWidth < 800;
                  double fontSizeTitle = isMobile ? screenWidth * 0.06 : screenWidth * 0.04;
                  double fontSizeSubtitle = isMobile ? screenWidth * 0.04 : screenWidth * 0.025;
                  double titleSpacing = isMobile ? 10 : 40;
                  double subtitleSpacing = isMobile ? 5 : 20;

                  return Column(
                    children: [
                      SizedBox(height: titleSpacing),
                      Text(
                        "The Next Generation of Manga Platform",
                        style: TextStyle(
                          fontSize: fontSizeTitle,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: subtitleSpacing),
                      Text(
                        "Track your progress, share with others, and discover new manga you'll love with Mangasaki.",
                        style: TextStyle(
                          fontSize: fontSizeSubtitle,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            // Segunda sección
            if (_isMobile)
              Column(
                children: [
                  CW_home(
                    icon: "assets/images/stats.svg",
                    title: "Discover and save your favorite mangas",
                    subtitle:
                        "Explore a wide collection of mangas, follow the chapters of your favorite series, and save them to always have them at your fingertips. Take your reading experience to the next level and never lose track of your favorite manga!",
                  ),
                  CW_home(
                    icon: "assets/images/social.svg",
                    title: "Join the community!",
                    subtitle:
                        "Add your friends, share your manga collections, and discover theirs. Share the mangas you've read and those on your to-read list to stay up-to-date and enjoy new recommendations together. The fun never ends when you share your passions!",
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: CW_home(
                      icon: "assets/images/stats.svg",
                      title: "Discover and save your favorite mangas",
                      subtitle:
                          "Explore a wide collection of mangas, follow the chapters of your favorite series, and save them to always have them at your fingertips. Take your reading experience to the next level and never lose track of your favorite manga!",
                    ),
                  ),
                  Expanded(
                    child: CW_home(
                      icon: "assets/images/social.svg",
                      title: "Join the community!",
                      subtitle:
                          "Add your friends, share your manga collections, and discover theirs. Share the mangas you've read and those on your to-read list to stay up-to-date and enjoy new recommendations together. The fun never ends when you share your passions!",
                    ),
                  ),
                ],
              ),
            // Tercera sección
            if (_isMobile)
              Column(
                children: [
                  CW_home(
                    icon: "assets/images/apps.svg",
                    title: "Bring Mangasaki anywhere",
                    subtitle:
                    "Keep track of your progress on-the-go with one of many Mangasaki apps across iOS, Android, macOS, and Windows.",
                  ),
                  CW_home(
                    icon: "assets/images/custom.svg",
                    title: "Customized to your liking!",
                    subtitle:
                    "We have different themes to change the style of the app!",
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: CW_home(
                      icon: "assets/images/apps.svg",
                      title: "Bring Mangasaki anywhere",
                      subtitle:
                          "Keep track of your progress on-the-go with one of many Mangasaki apps across iOS, Android, macOS, and Windows.",
                    ),
                  ),
                  Expanded(
                    child: CW_home(
                      icon: "assets/images/custom.svg",
                      title: "Customized to your liking!",
                      subtitle:
                          "We have different themes to change the style of the app!",
                    ),
                  ),
                ],
              ),
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
      SocialView(),
      TopMangasView(),
      MangaSearchView(),
    ];
    UserStorage.getUserData().then((userData) {
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

              // Asegurar que la imagen de perfil se recarga con un timestamp para evitar caché
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

                  //  MENÚ DE OPCIONES
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
                      ],
                    ),
                  ),

                  //  BOTÓN DE CIERRE DE SESIÓN
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                      disconnectWebsocket(context);
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
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationView(userId: userId!)),
                    );
                  }
                },
              ),
              if (pendingNotifications > 0)
                Positioned(
                  right: _isMobile ? 8:4,
                  top: _isMobile ? 8:3,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      pendingNotifications.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          if (Platform.isAndroid)
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen()),
                );
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Alto de la línea
          child: Container(
            color: Colors.black, // Color de la línea
            height: 2.0,
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

// Esto es para desconectarse

void disconnectWebsocket(BuildContext context) {
  // Crear un mapa con los datos del mensaje
  Map<String, dynamic> messageData = {
    "type": "disconnectRequest",
    "username": LoginScreen.username,
  };

  // Convertir el mapa a una cadena JSON
  String messageJson = jsonEncode(messageData);

  final appData = Provider.of<AppData>(context, listen: false);
  AppData.disconnectedForUser = true;
  appData.sendMessage(messageJson);
}