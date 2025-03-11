import 'package:flutter/material.dart';

class MangaWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;
  final double score;
  final int rank;
  final String description;

  const MangaWidget({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.score,
    required this.rank,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String cleanedDescription = description
        .replaceAll(RegExp(r'(\n|\[Written by MAL Rewrite\])'), '')
        .trim();
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
                    constraints: BoxConstraints(maxWidth: 450),
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Limpiar la descripción
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
                      // Columna para el statusWidget y starRating
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
                          starRating(score),
                          SizedBox(height: 15),
                          statusWidget(status),

                        ],
                      ),
                      // Rank alineado a la derecha
                      customRatingWidget(rank),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )


    );
  }

  Widget statusWidget(String status) {
    // Definir el color de acuerdo al estado
    Color statusColor;
    if (status == "On Hiatus") {
      statusColor = Colors.amberAccent; // Amarillo
    } else if (status == "Finished") {
      statusColor = Colors.red; // Rojo
    } else if (status == "Publishing") {
      statusColor = Colors.green; // Verde
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
    // El número total de estrellas es 5, cada una tiene un valor de 2 (0-10 puntos)
    int fullStars = rating ~/ 2; // Número de estrellas completas (de 0 a 5)
    double fractionalStar =
        rating - fullStars * 2; // Valor de la fracción de estrella (0 a 2)
    int emptyStars = 5 -
        fullStars -
        (fractionalStar >= 1 ? 1 : 0); // Número de estrellas vacías

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Generar estrellas completas
        ...List.generate(fullStars, (index) {
          return Icon(
            Icons.star,
            color: Colors.yellow,
            size: 20.0,
          );
        }),
        // Si hay una fracción (media estrella), añadir una estrella parcial
        if (fractionalStar >= 1)
          Icon(
            Icons.star_half,
            color: Colors.yellow,
            size: 20.0,
          ),
        // Generar estrellas vacías
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
    // Definir variables para el borde y el color de fondo según el rango del número
    Color borderColor;
    Color backgroundColor;
    double fontSize;

    // Determinar el color de borde, fondo y el tamaño de la fuente según el score
    if (score >= 1 && score <= 10) {
      borderColor = Colors.amber; // Dorado
      backgroundColor = Colors.black;
      fontSize = 16;
    } else if (score >= 11 && score <= 20) {
      borderColor = Colors.grey; // Plateado
      backgroundColor = Colors.black;
      fontSize = 14;
    } else if (score >= 21 && score <= 50) {
      borderColor = Colors.blueAccent; // Color bronce
      backgroundColor = Colors.white;
      fontSize = 12;
    } else if (score >= 51 && score <= 200) {
      borderColor = Colors.green; // Otro color
      backgroundColor = Colors.white;
      fontSize = 10;
    } else {
      borderColor = Colors.black; // Negro
      backgroundColor = Colors.white;
      fontSize = 8;
    }

    // Crear el widget con la configuración anterior
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor, // Color de fondo
        borderRadius: BorderRadius.circular(10), // Bordes redondeados
        border: Border.all(
          color: borderColor, // Color del borde
          width: 2, // Grosor del borde
        ),
      ),
      child: Text(
        '$score', // Mostrar el número como texto
        style: TextStyle(
          fontSize: fontSize, // Tamaño de la fuente según el rango
          fontWeight: FontWeight.bold,
          color: borderColor, // Color del texto, que debe resaltar
        ),
      ),
    );
  }
}
