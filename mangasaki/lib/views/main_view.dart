import 'package:flutter/material.dart';
import 'package:mangasaki/views/top_mangas_view.dart';
import 'package:mangasaki/widgets/widget_home_view.dart';
import 'package:provider/provider.dart';
import 'package:mangasaki/views/login_view.dart';

import '../widgets/global_state.dart';
import 'camera_screen.dart';
import 'notification_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;
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
            // Primer sección
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  SizedBox(height: (_isMobile ? 10 : 40)),
                  Text(
                    "The Next Generation of Manga Platform",
                    style: TextStyle(
                      fontSize: (_isMobile ? 25 : 40),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: (_isMobile ? 5 : 20)),
                  Text(
                    "Track your progress, share with others, and discover new manga you'll love with Mangasaki.",
                    style: TextStyle(
                      fontSize: (_isMobile ? 18 : 24),
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
      Center(
          child: Text('Profile',
              style: TextStyle(fontSize: 24, color: Colors.white))),
      Center(
          child: Text('Social',
              style: TextStyle(fontSize: 24, color: Colors.white))),
      TopMangasView(),
      Center(
          child: Text('Search',
              style: TextStyle(fontSize: 24, color: Colors.white))),
      Center(
          child: Text('Themes',
              style: TextStyle(fontSize: 24, color: Colors.white))),
    ];

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: Column(
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
                      backgroundImage: NetworkImage("https://picsum.photos/200/300?grayscale"), //imagen de prueba
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Provider.of<GlobalState>(context).username,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),



              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(Icons.home, color: Colors.white),
                      title:
                          Text('Home', style: TextStyle(color: Colors.white)),
                      onTap: () => _onItemTapped(0),
                    ),
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.white),
                      title: Text('Profile',
                          style: TextStyle(color: Colors.white)),
                      onTap: () => _onItemTapped(1),
                    ),
                    ListTile(
                      leading: Icon(Icons.group, color: Colors.white),
                      title:
                          Text('Social', style: TextStyle(color: Colors.white)),
                      onTap: () => _onItemTapped(2),
                    ),
                    ListTile(
                      leading: Icon(Icons.book, color: Colors.white),
                      title: Text('Top Mangas',
                          style: TextStyle(color: Colors.white)),
                      onTap: () => _onItemTapped(3),
                    ),
                    ListTile(
                      leading: Icon(Icons.search, color: Colors.white),
                      title:
                          Text('Search', style: TextStyle(color: Colors.white)),
                      onTap: () => _onItemTapped(4),
                    ),
                    ListTile(
                      leading: Icon(Icons.color_lens, color: Colors.white),
                      title:
                          Text('Themes', style: TextStyle(color: Colors.white)),
                      onTap: () => _onItemTapped(5),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text('Sign Out', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => (LoginScreen())),
                  );
                },
              ),
            ],
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
              // Acción cuando se toca la campanita
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationView()),
              );
            },
          ),
          if (MediaQuery.of(context).size.width < 600) // Solo en móviles
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () {
                // Acción cuando se toca la cámara
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen()),
                );
              },
            ),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }
}
