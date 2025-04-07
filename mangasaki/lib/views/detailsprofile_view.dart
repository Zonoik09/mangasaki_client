import 'package:flutter/material.dart';

class DetailsProfileView extends StatelessWidget {
  final int index;

  DetailsProfileView({required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalles del Jugador ${index + 1}")),
      body: Center(
        child: Text("Detalles para el jugador ${index + 1}"),
      ),
    );
  }
}
