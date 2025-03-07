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
          20),
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.black.withOpacity(0.1), width: 1), // Borde leve
        borderRadius: BorderRadius.circular(12), // Esquinas redondeadas
        color: Colors.transparent, // Fondo transparente
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .start,
        children: [
          // Imagen a la izquierda
          SvgPicture.asset(
            icon,
            width: 150.0,
            height: 150.0,
          ),
          SizedBox(width: 20),
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
                ),
                SizedBox(height: 8), // Espacio entre el título y el subtítulo
                // Subtítulo debajo del título, en blanco también
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14, // tamaño subt
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                  maxLines:
                      3,
                  overflow: TextOverflow
                      .ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
