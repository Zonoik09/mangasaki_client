import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connection/api_service.dart';
import '../connection/app_data.dart';
import '../connection/friendManager.dart';
import 'login_view.dart';

class MangaView extends StatefulWidget {
  final String name;
  final String description;
  final String status;
  final int ranking;
  final double score;
  final List<String> genres;
  final int chapters;
  final String imageUrl;
  final int id;

  const MangaView({
    Key? key,
    required this.name,
    required this.description,
    required this.status,
    required this.ranking,
    required this.score,
    required this.genres,
    required this.chapters,
    required this.imageUrl,
    required this.id,
  }) : super(key: key);

  @override
  _MangaViewState createState() => _MangaViewState();
}

class _MangaViewState extends State<MangaView> {
  String? _userMangaStatus;

  @override
  void initState() {
    super.initState();
    _fetchUserMangaStatus();
  }

  Future<void> _fetchUserMangaStatus() async {
    try {
      final usuario = await ApiService().getUserInfo(LoginScreen.username);
      final userId = usuario["resultat"]["id"];
      final mangas = await ApiService().getUserMangas(userId);

      // Obtén los mangas clasificados por estado
      final mangaStatus = mangas["data"];

      // Revisa en qué estado se encuentra el manga
      if (mangaStatus["READING"]?.contains(widget.id) ?? false) {
        setState(() {
          _userMangaStatus = 'READING';
        });
      } else if (mangaStatus["COMPLETED"]?.contains(widget.id) ?? false) {
        setState(() {
          _userMangaStatus = 'COMPLETED';
        });
      } else if (mangaStatus["PENDING"]?.contains(widget.id) ?? false) {
        setState(() {
          _userMangaStatus = 'PENDING';
        });
      } else if (mangaStatus["ABANDONED"]?.contains(widget.id) ?? false) {
        setState(() {
          _userMangaStatus = 'ABANDONED';
        });
      }
    } catch (e) {
      print("Failed to fetch user manga status: $e");
    }
  }


  Future<void> _handleStatusTap(String newStatus) async {
    final usuario = await ApiService().getUserInfo(LoginScreen.username);
    final userId = usuario["resultat"]["id"];

    if (_userMangaStatus == newStatus) {
      // Already has the status, ask to remove
      final confirmed = await _showConfirmationDialog(
        title: "Confirmation",
        content: "This manga is already marked as '$newStatus'. Do you want to remove this status?",
      );
      if (confirmed) {
        await ApiService().removeMangaStatus(userId, widget.id);
        setState(() {
          _userMangaStatus = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status removed."), backgroundColor: Colors.green),
        );
      }
    } else {
      // Add or change status
      await ApiService().mvMangaByStatus(userId, newStatus, widget.id);
      setState(() {
        _userMangaStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Manga marked as '$newStatus'."),backgroundColor: Colors.green),
      );
    }
  }

  Future<bool> _showConfirmationDialog({required String title, required String content}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(child: const Text("No"), onPressed: () => Navigator.of(context).pop(false)),
          TextButton(child: const Text("Yes"), onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    return result ?? false;
  }

  Color _getIconColor(String status) {
    return _userMangaStatus == status ? Colors.yellow : Colors.white;
  }

  void sendRecommendationToFriend({
    required BuildContext context,
    required int senderUserId,
    required String receiverUsername,
    required int mangaId,
  }) {
    final message = {
      'type': 'recommendation_notification',
      'sender_user_id': senderUserId,
      'receiver_username': receiverUsername,
      'manga_id': mangaId,
    };
    final jsonMessage = jsonEncode(message);
    final appData = Provider.of<AppData>(context, listen: false);
    // Enviar el mensaje JSON a través de WebSocket como una cadena
    appData.onNotificationSent = (message) {
      if (!mounted) return;
      final snackBar = SnackBar(content: Text(message), backgroundColor: Colors.green,);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    };
    appData.sendMessage(jsonMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              try {
                final friendManager = Provider.of<FriendManager>(context, listen: false);
                final friends = friendManager.allFriends;
                final usuario = await ApiService().getUserInfo(LoginScreen.username);
                final fromId = usuario["resultat"]["id"];
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Please, choose a friend to share this manga'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            final username = friend['name'];
                            return ListTile(
                              title: Text(username),
                              onTap: () {
                                Navigator.of(context).pop();
                                sendRecommendationToFriend(
                                  context: context,
                                  senderUserId: fromId,
                                  receiverUsername: username,
                                  mangaId: widget.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Recommendation sent to $username'),backgroundColor: Colors.green),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}'),backgroundColor: Colors.red),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              try {
                final galleries = await ApiService().getGallery(LoginScreen.username);
                final List<dynamic> galleryList = galleries["resultat"];
                final List<String> collectionNames = galleryList.map((g) => g["name"].toString()).toList();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Please choose one of your existing collections'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: collectionNames.length,
                          itemBuilder: (context, index) {
                            final collection = collectionNames[index];
                            return ListTile(
                              title: Text(collection),
                              onTap: () {
                                Navigator.of(context).pop();
                                ApiService().addInGallery(
                                  LoginScreen.username,
                                  collection,
                                  widget.id,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.menu_book, color: _getIconColor('READING')),
            onPressed: () => _handleStatusTap('READING'),
          ),
          IconButton(
            icon: Icon(Icons.hourglass_empty, color: _getIconColor('PENDING')),
            onPressed: () => _handleStatusTap('PENDING'),
          ),
          IconButton(
            icon: Icon(Icons.done_all, color: _getIconColor('COMPLETED')),
            onPressed: () => _handleStatusTap('COMPLETED'),
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: _getIconColor('ABANDONED')),
            onPressed: () => _handleStatusTap('ABANDONED'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manga Info", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8.0, offset: Offset(0, 4))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    widget.imageUrl,
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            starRating(widget.score),
                            const SizedBox(width: 8),
                            statusWidget(widget.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        customRatingWidget(widget.ranking),
                        const SizedBox(height: 8),
                        GenreWidget(widget.genres),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text("Synopsis", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(top: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8.0, offset: Offset(0, 4))],
              ),
              child: Text(widget.description, style: TextStyle(color: Colors.black87)),
            ),
            const SizedBox(height: 16),
            if (widget.chapters > 0) ...[
              Text("Chapters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              Divider(color: Colors.black, thickness: 2),
              Text("Total Chapters: ${widget.chapters}", style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.chapters,
                separatorBuilder: (context, index) => Divider(color: Colors.grey),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("${widget.name} - Chapter ${index + 1}",
                        style: TextStyle(color: Colors.black)),
                  );
                },
              ),
            ] else
              const Center(
                child: Text(
                  "Chapters are not available at the moment.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Reutilizar widgets auxiliares
  Widget statusWidget(String status) {
    final color = {
      "On Hiatus": Colors.amber,
      "Finished": Colors.red,
      "Publishing": Colors.green
    }[status] ?? Colors.grey;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget starRating(double rating) {
    int fullStars = rating ~/ 2;
    double fractionalStar = rating - fullStars * 2;
    int emptyStars = 5 - fullStars - (fractionalStar >= 1 ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(fullStars, (_) => Icon(Icons.star, color: Colors.amber, size: 20)),
        if (fractionalStar >= 1) Icon(Icons.star_half, color: Colors.amber, size: 20),
        ...List.generate(emptyStars, (_) => Icon(Icons.star_border, color: Colors.amber, size: 20)),
      ],
    );
  }

  Widget customRatingWidget(int score) {
    Color borderColor;
    Color backgroundColor;
    double fontSize;

    if (score <= 10) {
      borderColor = Colors.amber;
      backgroundColor = Colors.black;
      fontSize = 16;
    } else if (score <= 20) {
      borderColor = Colors.grey;
      backgroundColor = Colors.black;
      fontSize = 14;
    } else if (score <= 50) {
      borderColor = Colors.blueAccent;
      backgroundColor = Colors.white;
      fontSize = 12;
    } else if (score <= 200) {
      borderColor = Colors.green;
      backgroundColor = Colors.white;
      fontSize = 10;
    } else {
      borderColor = Colors.black;
      backgroundColor = Colors.white;
      fontSize = 8;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text("#$score", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: borderColor)),
    );
  }

  Widget GenreWidget(List<String> genres) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 60, 111, 150),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text(genre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }
}
