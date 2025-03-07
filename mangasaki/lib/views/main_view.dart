import 'package:flutter/material.dart';
import 'package:mangasaki/widgets/widget_home_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _principalView(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Align(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 60, 111, 150),
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Primer sección (parte superior)
              Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      Text(
                        "The Next Generation of Manga Platform",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Track your progress, share with others, and discover new manga you'll love with Mangasaki.",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
              // Segunda sección (parte inferior) - 50% de la altura
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Row(
                  children: [
                    // Columna izquierda (50% del ancho)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: CW_home(
                        icon: "assets/images/stats.svg",
                        title: "Discover and save your favorite mangas",
                        subtitle:
                            "Explora una amplia colección de mangas, sigue los capítulos de tus series favoritas y guárdalos para tenerlos siempre a tu alcance. ¡Lleva tu experiencia de lectura al siguiente nivel y nunca pierdas el hilo de tu manga preferido!",
                      ),
                    ),
                    // Columna derecha (50% del ancho)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: CW_home(
                        icon: "assets/images/social.svg",
                        title: "Join the community!",
                        subtitle:
                            "Add your friends, share your manga collections, and discover theirs. Share the mangas you've read and those on your to-read list to stay up-to-date and enjoy new recommendations together. The fun never ends when you share your passions!",
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Row(
                  children: [
                    // Columna izquierda (50% del ancho)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: CW_home(
                        icon: "assets/images/apps.svg",
                        title: "Bring Mangasaki anywhere",
                        subtitle:
                            "Keep track of your progress on-the-go with one of many Mangasaki apps across iOS, Android, macOS, and Windows.",
                      ),
                    ),
                    // Columna derecha (50% del ancho)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: CW_home(
                        icon: "assets/images/custom.svg",
                        title: "Customized to your liking!",
                        subtitle:
                            "We have different themes to change the style of the app!",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      Center(
          child: Text('Top Mangas',
              style: TextStyle(fontSize: 24, color: Colors.white))),
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
              UserAccountsDrawerHeader(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 60, 111, 150)),
                accountName:
                    Text("Usuario", style: TextStyle(color: Colors.white)),
                accountEmail: null,
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.red,
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
                  // Implementar la lógica de cierre de sesión aquí
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
      ),
      body: _pages[_selectedIndex],
    );
  }
}
