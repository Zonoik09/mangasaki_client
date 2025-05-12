import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:mangasaki/views/login_view.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

import '../connection/api_service.dart';
import '../connection/app_data.dart';
import '../connection/friendManager.dart';
import '../widgets/Friend_widget.dart';
import '../widgets/manga_widget_Recomendation.dart';
import 'addFriend_view.dart';

class SocialView extends StatefulWidget {
  @override
  _SocialViewState createState() => _SocialViewState();
}

class _SocialViewState extends State<SocialView> {
  final List<Map<String, dynamic>> allFriends = FriendManager().allFriends;
  late Timer _timer;
  late List<Map<String, dynamic>> recommendations = [];
  bool isLoadingRecommendations = true;


  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    final letters = _searchController.text.trim();
    if (letters.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFriendView(letters: letters),
        ),
      );
    }
  }

  void _getRecommendations() async {
    setState(() {
      isLoadingRecommendations = true; // Iniciar el indicador de carga
    });
    try {
      // Obtener el ID del usuario a partir del username
      final usuario = await ApiService().getUserInfo(LoginScreen.username);
      final fromId = usuario["resultat"]["id"];

      // Obtener los IDs de manga recomendados
      final List<int> mangaIds = await ApiService().getRecommendedMangas(fromId);

      List<Map<String, dynamic>> fetchedMangas = [];

      // Lógica para cargar en lotes de 3 mangas
      for (int i = 0; i < mangaIds.length; i += 2) {
        // Cargar los próximos 3 mangas (o menos si es el final)
        final batchIds = mangaIds.sublist(
            i, (i + 2) > mangaIds.length ? mangaIds.length : i + 2);

        // Procesar cada manga en este lote
        for (int id in batchIds) {
          try {
            final mangaData = await ApiService().searchManga(id);
            fetchedMangas.add({
              'title': mangaData['title'],
              'imageUrl': mangaData['imageUrl'],
              'status': mangaData['status'],
              'score': mangaData['score'],
              'rank': mangaData['rank'],
              'description': mangaData['description'],
              'chapters': mangaData['chapters'],
              'genres': List<String>.from(mangaData['genres'] ?? []),
              'type': mangaData['type'],
              'id': id
            });
          } catch (e) {
            print('Error cargando manga con ID $id: $e');
          }
        }

        // Esperar 1 segundo antes de cargar el siguiente lote
        await Future.delayed(Duration(seconds: 1));
      }

      // Actualizar el estado con los mangas cargados
      setState(() {
        recommendations.clear();
        recommendations.addAll(fetchedMangas);
        isLoadingRecommendations = false;
      });
    } catch (e) {
      print('Error loading recommendations: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Llama a la función para obtener los amigos iniciales
    _getFriends();
    _getRecommendations();

    // Configura el Timer para actualizar los amigos cada 10 segundos
    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      _getFriends();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollRecommendations(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  void _getFriends() {
    // Crear un mapa con los datos del mensaje
    Map<String, dynamic> messageData = {
      "type": "getFriendsOnlineOffline",
      "username": LoginScreen.username,
    };

    // Convertir el mapa a una cadena JSON
    String messageJson = jsonEncode(messageData);
    final appData = Provider.of<AppData>(context, listen: false);
    appData.sendMessage(messageJson);

  }

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
                controller: _searchController,
                onSubmitted: (_) => _performSearch(),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.grey),
                    onPressed: _performSearch,
                  ),
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
                isLoadingRecommendations
                    ? Center(child: CircularProgressIndicator())
                    : Platform.isWindows || Platform.isLinux
                    ? Column(
                  children: [
                    SizedBox(
                      height: 320,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: recommendations.map((manga) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: MangaWidgetRecomendation(
                                title: manga['title'],
                                imageUrl: manga['imageUrl'],
                                status: manga['status'],
                                score: manga['score'].toDouble(),
                                rank: manga['rank'],
                                description: manga['description'],
                                chapters: manga['chapters'],
                                genres: List<String>.from(manga['genres']),
                                type: manga['type'],
                                id: manga["id"],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                          padding: EdgeInsets.all(4),
                          constraints: BoxConstraints(),
                          onPressed: () => _scrollRecommendations(-300),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          padding: EdgeInsets.all(4),
                          constraints: BoxConstraints(),
                          onPressed: () => _scrollRecommendations(300),
                        ),
                      ],
                    ),
                  ],
                )
                    : SizedBox(
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
                            score: manga['score'].toDouble(),
                            rank: manga['rank'],
                            description: manga['description'],
                            chapters: manga['chapters'],
                            genres: List<String>.from(manga['genres']),
                            type: manga['type'],
                            id: manga["id"],
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
                Text('Friends',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                // Friends Online
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Friends Online',
                      style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600),
                    ),
                    children: [
                      // Usar Consumer para escuchar los amigos
                      Consumer<FriendManager>(
                        builder: (context, friendManager, child) {
                          return Column(
                            children: friendManager.allFriends
                                .where((friend) => friend['online'] == true)
                                .map((friend) {
                              return FutureBuilder<Uint8List>(
                                future:
                                    ApiService().getUserImage(friend['name']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError ||
                                      !snapshot.hasData) {
                                    return friendWidget(
                                      username: friend['name'],
                                      image: null,
                                      online: true,
                                    );
                                  } else {
                                    return friendWidget(
                                      username: friend['name'],
                                      image: snapshot.data,
                                      online: true,
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // Friends Offline
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      'Friends Offline',
                      style: TextStyle(
                          color: Colors.red[700], fontWeight: FontWeight.w600),
                    ),
                    children: [
                      // Usar Consumer para escuchar los amigos
                      Consumer<FriendManager>(
                        builder: (context, friendManager, child) {
                          return Column(
                            children: friendManager.allFriends
                                .where((friend) => friend['online'] == false)
                                .map((friend) {
                              return FutureBuilder<Uint8List>(
                                future:
                                    ApiService().getUserImage(friend['name']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError ||
                                      !snapshot.hasData) {
                                    return friendWidget(
                                      username: friend['name'],
                                      image: null,
                                      online: false,
                                    );
                                  } else {
                                    return friendWidget(
                                      username: friend['name'],
                                      image: snapshot.data,
                                      online: false,
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
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
