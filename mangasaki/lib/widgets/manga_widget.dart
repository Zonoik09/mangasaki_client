import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Si es necesario para la navegación
import 'package:mangasaki/views/manga_view.dart';

class MangaWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;
  final double score;
  final int rank;
  final String description;
  final int chapters;
  final List<String> genres;

  const MangaWidget({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.score,
    required this.rank,
    required this.description,
    required this.chapters,
    required this.genres,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String cleanedDescription = description
        .replaceAll(RegExp(r'(\n|\[Written by MAL Rewrite\])'), '')
        .trim();

    return GestureDetector(
      onTap: () {
        // Navegar a MangaView cuando se hace clic en el widget
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaView(
              name: title,
              description: cleanedDescription,
              status: status,
              ranking: rank,
              score: score,
              genres: genres,
              chapters: chapters ?? -1,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Card(
        color: Color.fromARGB(255, 60, 111, 150),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Image.network(imageUrl, height: 200, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 450),
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 450),
                    child: Text(
                      cleanedDescription,
                      style: TextStyle(fontSize: 14),
                      maxLines: 3, // Limitar a un máximo de 3 líneas
                      overflow: TextOverflow.ellipsis, // Mostrar "..." si el texto excede 3 líneas
                    ),
                  ),
                  // Row para distribuir el Column (status + starRating) y rank a la derecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: 60),
                      starRating(score),
                      SizedBox(width: 20),
                      statusWidget(status),
                      SizedBox(width: 150, height: 62,),
                      customRatingWidget(rank),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      fontSize = 18;
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
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Text(
        '#$score',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: borderColor,
        ),
      ),
    );
  }
}
