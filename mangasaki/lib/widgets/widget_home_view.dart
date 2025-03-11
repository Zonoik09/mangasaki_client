import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CW_home extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  CW_home({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.0), width: 1),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.00),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.0),
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: isMobile
          ? SingleChildScrollView(
              child: CWHomeMobile(icon: icon, title: title, subtitle: subtitle),
            )
          : CWHomeDesktop(icon: icon, title: title, subtitle: subtitle),
    );
  }
}

class CWHomeMobile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  CWHomeMobile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column( // Apila los elementos en pantallas pequeñas
      mainAxisSize: MainAxisSize.min, // Minimiza el espacio ocupado
      children: [
        SvgPicture.asset(
          icon,
          width: screenWidth * 0.2, // Ajusta el tamaño del ícono
          height: screenWidth * 0.2, // Ajusta el tamaño del ícono
        ),
        SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.05, // Ajusta el tamaño del texto
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: screenWidth * 0.04, // Ajusta el tamaño del texto
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class CWHomeDesktop extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  CWHomeDesktop({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        return Align(
          alignment: Alignment.bottomCenter, // Asegura que los elementos se alineen al fondo
          child: Row( // Mantiene la disposición horizontal en pantallas grandes
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                icon,
                width: screenWidth * 0.1, // Ajusta el tamaño del ícono
                height: screenWidth * 0.1, // Ajusta el tamaño del ícono
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05, // Ajusta el tamaño del texto
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Ajusta el tamaño del texto
                        color: Colors.white70,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
