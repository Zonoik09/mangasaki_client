import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CW_home extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  // Constructor para recibir los valores del icono, título y subtítulo
  CW_home({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Contenedor transparente con borde
      padding: EdgeInsets.all(
          20), // Aumenté el padding para hacer el recuadro más grande
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.black.withOpacity(0.1), width: 1), // Borde leve
        borderRadius: BorderRadius.circular(12), // Esquinas redondeadas
        color: Colors.transparent, // Fondo transparente
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .start, // Alinea el icono y el texto correctamente
        children: [
          // Imagen a la izquierda
          SvgPicture.asset(
            icon,
            width: 150.0, // Puedes ajustar el tamaño
            height: 150.0, // Puedes ajustar el tamaño
          ),
          SizedBox(width: 20), // Espacio entre la imagen y el texto
          Expanded(
            // Aquí usamos Expanded para que el texto ocupe el espacio restante
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título en blanco y en negrita
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22, // Aumenté el tamaño del texto
                    fontWeight: FontWeight.bold, // Texto en negrita
                    color: Colors.white, // Color blanco para el título
                  ),
                  maxLines:
                      2, // Limita el número de líneas en el título si es necesario
                  overflow: TextOverflow
                      .ellipsis, // Agrega "..." si el texto es más largo de lo que cabe
                ),
                SizedBox(height: 8), // Espacio entre el título y el subtítulo
                // Subtítulo debajo del título, en blanco también
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16, // Tamaño adecuado para el subtítulo
                    fontWeight: FontWeight.normal, // Texto normal
                    color: Colors.white, // Color blanco para el subtítulo
                  ),
                  maxLines:
                      4, // Limita el número de líneas en el subtítulo si es necesario
                  overflow: TextOverflow
                      .ellipsis, // Agrega "..." si el texto es más largo de lo que cabe
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
