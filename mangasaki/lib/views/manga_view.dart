import 'package:flutter/material.dart';

import '../connection/api_service.dart';
import 'login_view.dart';

class MangaView extends StatelessWidget {
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

  Widget statusWidget(String status) {
    Color statusColor;
    if (status == "On Hiatus") {
      statusColor = Colors.amber;
    } else if (status == "Finished") {
      statusColor = Colors.red;
    } else if (status == "Publishing") {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget GenreWidget(List<String> generos) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: generos.map((genero) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 60, 111, 150),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text(
            genero,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }



  Widget starRating(double rating) {
    int fullStars = rating ~/ 2;
    double fractionalStar = rating - fullStars * 2;
    int emptyStars = 5 - fullStars - (fractionalStar >= 1 ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(fullStars, (index) {
          return Icon(
            Icons.star,
            color: Colors.yellow,
            size: 20.0,
          );
        }),
        if (fractionalStar >= 1)
          Icon(
            Icons.star_half,
            color: Colors.yellow,
            size: 20.0,
          ),
        ...List.generate(emptyStars, (index) {
          return Icon(
            Icons.star_border,
            color: Colors.yellow,
            size: 20.0,
          );
        }),
      ],
    );
  }

  Widget customRatingWidget(int score) {
    Color borderColor;
    Color backgroundColor;
    double fontSize;

    if (score >= 1 && score <= 10) {
      borderColor = Colors.amber;
      backgroundColor = Colors.black;
      fontSize = 16;
    } else if (score >= 11 && score <= 20) {
      borderColor = Colors.grey;
      backgroundColor = Colors.black;
      fontSize = 14;
    } else if (score >= 21 && score <= 50) {
      borderColor = Colors.blueAccent;
      backgroundColor = Colors.white;
      fontSize = 12;
    } else if (score >= 51 && score <= 200) {
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
      child: Text(
        "#$ranking",
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: borderColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 60, 111, 150),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
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
                        title: const Text('Selecciona una colección'),
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
                                  Navigator.of(context).pop(); // Cierra el diálogo
                                  ApiService().addInGallery(
                                    LoginScreen.username,
                                    collection,
                                    id,
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
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  imageUrl,
                  width: MediaQuery.of(context).size.width < 600 ? 100 : 150,
                  height: MediaQuery.of(context).size.width < 600 ? 150 : 225,
                  fit: BoxFit.cover,
                ),                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          starRating(score),
                          const SizedBox(width: 8),
                          statusWidget(status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      customRatingWidget(ranking),
                      const SizedBox(height: 8),
                      GenreWidget(genres),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(description, style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            if (chapters > 0) ...[
              Text("Chapters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Divider(color: Colors.white, thickness: 2),
              Text("Total Chapters: $chapters", style: TextStyle(fontSize: 16, color: Colors.white)),
              const SizedBox(height: 8),
            ],
            if (chapters <= 0)
              const Center(
                child: Text(
                  "Chapters are not available at the moment.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )
            else
            // Usamos ListView directamente sin Expanded ni shrinkWrap
              ListView.separated(
                shrinkWrap: true, // Para que el ListView ocupe solo el espacio necesario
                physics: NeverScrollableScrollPhysics(), // Desactiva el desplazamiento dentro del ListView
                itemCount: chapters,
                separatorBuilder: (context, index) => Divider(color: Colors.grey),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("$name - Chapter ${index + 1}", style: TextStyle(color: Colors.white)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.favorite_border, color: Colors.white),
                        SizedBox(width: 8),
                        Icon(Icons.bookmark_border, color: Colors.white),
                        SizedBox(width: 8),
                        Icon(Icons.remove_red_eye, color: Colors.white),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
