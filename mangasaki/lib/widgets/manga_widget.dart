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
  final String type;

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
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String cleanedDescription = description
        .replaceAll(RegExp(r'(\n|\[Written by MAL Rewrite\])'), '')
        .trim();
    String newTitle = title;
    if (type != "Manga") {
      newTitle = title+"  ($type)";
    }
    return GestureDetector(
      onTap: () {
        // Navegar a MangaView cuando se hace clic en el widget
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaView(
              name: newTitle,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          double cardWidth = constraints.maxWidth;
          double cardHeight = constraints.maxHeight;
          print("$cardWidth | $cardHeight");
          return Card(
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
                        constraints: BoxConstraints(
                          maxWidth: cardWidth < 562.0 ? cardWidth * 0.6 : cardWidth * 0.7,
                        ),
                        child: Text(
                          newTitle,
                          style: TextStyle(fontSize: cardHeight < 190 ? 15 : 18, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: cardWidth < 562.0 ? cardWidth * 0.6 : cardWidth * 0.7,
                        ),
                        child: Text(
                          cleanedDescription,
                          style: TextStyle(fontSize: cardHeight < 190 ? 12 : 14, color: Colors.white),
                          maxLines: cardHeight < 190 ? 2:3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: cardHeight * 0.2),
                          cardWidth < 448.0
                              ? Column(
                            children: [
                              Row(
                                children: [
                                  starRating(score),
                                  SizedBox(width: cardWidth * 0.03),
                                  statusWidget(status),
                                ],
                              ),
                              SizedBox(height: 8),
                              customRatingWidget(rank),
                            ],
                          )
                              : Row(
                            children: [
                              starRating(score),
                              SizedBox(width: cardWidth * 0.03),
                              statusWidget(status),
                              SizedBox(width: cardWidth < 562.0 ? cardWidth * 0.05 : cardWidth * 0.1, height: cardHeight < 190 ? cardHeight * 0.15: cardHeight * 0.3),
                              customRatingWidget(rank),
                            ],
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          );
        },
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

class MangaWidgetMobile extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;
  final double score;
  final int rank;
  final String description;
  final int chapters;
  final List<String> genres;
  final String type;

  const MangaWidgetMobile({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.score,
    required this.rank,
    required this.description,
    required this.chapters,
    required this.genres,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String cleanedDescription = description
        .replaceAll(RegExp(r'(\n|\[Written by MAL Rewrite\])'), '')
        .trim();
    String newTitle = title;
    if (type != "manga") {
      newTitle = title+"  ($type)";
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaView(
              name: newTitle,
              description: cleanedDescription,
              status: status,
              ranking: rank,
              score: score,
              genres: genres,
              chapters: chapters,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Card(
        color: const Color.fromARGB(255, 60, 111, 150),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen del manga con status y estrellas debajo
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 90,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  statusWidget(status),
                  const SizedBox(height: 6),
                  starRating(score),
                ],
              ),

              const SizedBox(width: 10),

              // Detalles del manga a la derecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cleanedDescription,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    customRatingWidget(rank),
                  ],
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
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
          return const Icon(
            Icons.star,
            color: Colors.yellow,
            size: 18.0,
          );
        }),
        if (fractionalStar >= 1)
          const Icon(
            Icons.star_half,
            color: Colors.yellow,
            size: 18.0,
          ),
        ...List.generate(emptyStars, (index) {
          return const Icon(
            Icons.star_border,
            color: Colors.yellow,
            size: 18.0,
          );
        }),
      ],
    );
  }

  Widget customRatingWidget(int rank) {
    Color borderColor;
    Color backgroundColor;
    double fontSize;

    if (rank >= 1 && rank <= 10) {
      borderColor = Colors.amber;
      backgroundColor = Colors.black;
      fontSize = 18;
    } else if (rank >= 11 && rank <= 20) {
      borderColor = Colors.grey;
      backgroundColor = Colors.black;
      fontSize = 14;
    } else if (rank >= 21 && rank <= 50) {
      borderColor = Colors.blueAccent;
      backgroundColor = Colors.white;
      fontSize = 12;
    } else if (rank >= 51 && rank <= 200) {
      borderColor = Colors.green;
      backgroundColor = Colors.white;
      fontSize = 10;
    } else {
      borderColor = Colors.black;
      backgroundColor = Colors.white;
      fontSize = 8;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Text(
        '#$rank',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: borderColor,
        ),
      ),
    );
  }
}


