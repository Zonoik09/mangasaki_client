import 'package:flutter/material.dart';

import '../widgets/Friend_widget.dart';

class SocialView extends StatefulWidget {
  @override
  _SocialViewState createState() => _SocialViewState();
}

class _SocialViewState extends State<SocialView> {
  final List<Map<String, dynamic>> allFriends = [
    {'name': 'Alice', 'image': 'https://i.pravatar.cc/150?img=1', 'online': true},
    {'name': 'Bob', 'image': 'https://i.pravatar.cc/150?img=2', 'online': true},
    {'name': 'Charlie', 'image': 'https://i.pravatar.cc/150?img=3', 'online': true},
    {'name': 'Dave', 'image': 'https://i.pravatar.cc/150?img=4', 'online': false},
    {'name': 'Eve', 'image': 'https://i.pravatar.cc/150?img=5', 'online': false},
    {'name': 'Frank', 'image': 'https://i.pravatar.cc/150?img=6', 'online': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [

          // Buscador alineado a la derecha
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 200,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  suffixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Recuadro de recomendaciones
// Recuadro de recomendaciones
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 60, 111, 150),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                // Aquí va tu widget personalizado
                //MangaWidgetRecomendation(),
              ],
            ),
          ),


          SizedBox(height: 20),

          // Sección Friends
          // FRIENDS SECTION
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Friends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                // Friends Online
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Friends Online',
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                    ),
                    children: allFriends
                        .where((friend) => friend['online'] == true)
                        .map((friend) => friendWidget(
                      username: friend['name'],
                      image: friend['image'],
                      online: true,
                    ))
                        .toList(),
                  ),
                ),

                SizedBox(height: 10),

                // Friends Offline
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Friends Offline',
                      style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w600),
                    ),
                    children: allFriends
                        .where((friend) => friend['online'] == false)
                        .map((friend) => friendWidget(
                      username: friend['name'],
                      image: friend['image'],
                      online: false,
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
