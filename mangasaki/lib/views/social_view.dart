import 'package:flutter/material.dart';

import '../widgets/Friend_widget.dart';
import '../widgets/manga_widget_Recomendation.dart';

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

  final List<Map<String, dynamic>> recommendations = [
    {
      'title': 'One Piece',
      'imageUrl': 'https://cdn.myanimelist.net/images/manga/3/55539.jpg',
      'status': 'Publishing',
      'score': 9.1,
      'rank': 1,
      'description': 'Gol D. Roger was known as the Pirate King. The capture and death of Roger by the World Government brought a change throughout the world...',
      'chapters': 1095,
      'genres': ['Action', 'Adventure', 'Fantasy'],
      'type': 'Manga',
      'nickname': 'Alice',
    },
    {
      'title': 'Solo Leveling',
      'imageUrl': 'https://cdn.myanimelist.net/images/manga/3/222121.jpg',
      'status': 'Finished',
      'score': 8.7,
      'rank': 23,
      'description': 'In a world where hunters—human warriors who possess magical abilities—must battle deadly monsters to protect mankind from annihilation...',
      'chapters': 179,
      'genres': ['Action', 'Fantasy', 'Supernatural'],
      'type': 'Manhwa',
      'nickname': 'Bob',
    },
    {
      'title': 'One Piece',
      'imageUrl': 'https://cdn.myanimelist.net/images/manga/3/55539.jpg',
      'status': 'Publishing',
      'score': 9.1,
      'rank': 1,
      'description': 'Gol D. Roger was known as the Pirate King. The capture and death of Roger by the World Government brought a change throughout the world...',
      'chapters': 1095,
      'genres': ['Action', 'Adventure', 'Fantasy'],
      'type': 'Manga',
      'nickname': 'Alice',
    },
    {
      'title': 'Solo Leveling',
      'imageUrl': 'https://cdn.myanimelist.net/images/manga/3/222121.jpg',
      'status': 'Finished',
      'score': 8.7,
      'rank': 23,
      'description': 'In a world where hunters—human warriors who possess magical abilities—must battle deadly monsters to protect mankind from annihilation...',
      'chapters': 179,
      'genres': ['Action', 'Fantasy', 'Supernatural'],
      'type': 'Manhwa',
      'nickname': 'Bob',
    },
    {
      'title': 'One Piece',
      'imageUrl': 'https://cdn.myanimelist.net/images/manga/3/55539.jpg',
      'status': 'Publishing',
      'score': 9.1,
      'rank': 1,
      'description': 'Gol D. Roger was known as the Pirate King. The capture and death of Roger by the World Government brought a change throughout the world...',
      'chapters': 1095,
      'genres': ['Action', 'Adventure', 'Fantasy'],
      'type': 'Manga',
      'nickname': 'Alice',
    },
    {
      'title': 'Solo Leveling',
      'imageUrl': 'https://cdn.myanimelist.net/images/manga/3/222121.jpg',
      'status': 'Finished',
      'score': 8.7,
      'rank': 23,
      'description': 'In a world where hunters—human warriors who possess magical abilities—must battle deadly monsters to protect mankind from annihilation...',
      'chapters': 179,
      'genres': ['Action', 'Fantasy', 'Supernatural'],
      'type': 'Manhwa',
      'nickname': 'Bob',
    },
    {
      'title': 'One Piece',
      'imageUrl': 'https://cdn.myanimelist.net/images/manga/3/55539.jpg',
      'status': 'Publishing',
      'score': 9.1,
      'rank': 1,
      'description': 'Gol D. Roger was known as the Pirate King. The capture and death of Roger by the World Government brought a change throughout the world...',
      'chapters': 1095,
      'genres': ['Action', 'Adventure', 'Fantasy'],
      'type': 'Manga',
      'nickname': 'Alice',
    },
    {
      'title': 'Solo Leveling',
      'imageUrl': 'https://cdn.myanimelist.net/images/manga/3/222121.jpg',
      'status': 'Finished',
      'score': 8.7,
      'rank': 23,
      'description': 'In a world where hunters—human warriors who possess magical abilities—must battle deadly monsters to protect mankind from annihilation...',
      'chapters': 179,
      'genres': ['Action', 'Fantasy', 'Supernatural'],
      'type': 'Manhwa',
      'nickname': 'Bob',
    },
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
          Container(
            width: double.infinity,
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
                Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 320,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recommendations.map((manga) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: MangaWidgetRecomendation(
                            title: manga['title'],
                            imageUrl: manga['imageUrl'],
                            status: manga['status'],
                            score: manga['score'],
                            rank: manga['rank'],
                            description: manga['description'],
                            chapters: manga['chapters'],
                            genres: List<String>.from(manga['genres']),
                            type: manga['type'],
                            nickname: manga['nickname'],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Sección Friends
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
