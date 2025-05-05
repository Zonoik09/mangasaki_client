import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mangasaki/widgets/addFriend_widget.dart';
import '../connection/api_service.dart';

class AddFriendView extends StatefulWidget {
  final String letters;

  const AddFriendView({Key? key, required this.letters}) : super(key: key);

  @override
  _AddFriendViewState createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<AddFriendView> {
  Map<String, dynamic> users = {}; // Inicializar como un Map vacío
  bool isLoading = true;
  Map<String, Uint8List> userImages = {}; // Para almacenar imágenes de cada usuario

  @override
  void initState() {
    super.initState();
    fetchUsers(widget.letters); // Llamar la función para obtener los usuarios
  }

  Future<void> fetchUsers(String letters) async {
    try {
      final result = await ApiService().getUsersFriends(letters);
      if (!mounted) return;
      setState(() {
        users = result; // Asignar el Map de usuarios
        isLoading = false;
      });
    } catch (e) {
      print("Error al cargar usuarios: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Uint8List> getUserImage(String nickname) async {
    // Si ya se ha descargado la imagen, la devuelve directamente desde el cache
    if (userImages.containsKey(nickname)) {
      return userImages[nickname]!;
    }

    // Si la imagen no está en el cache, la descargamos
    try {
      final image = await ApiService().getUserImage(nickname);
      setState(() {
        userImages[nickname] = image; // Guardar en el cache
      });
      return image;
    } catch (e) {
      throw Exception("Error al cargar la imagen del usuario");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> userList = users['data'] ?? [];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 60, 111, 150),
      appBar: AppBar(
        title: const Text("Agregar Amigos"),
        backgroundColor: Color.fromARGB(255, 60, 111, 150),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: userList.length,
        itemBuilder: (context, index) {
          final user = userList[index];
          return FutureBuilder<Uint8List>(
            future: getUserImage(user['nickname']), // Usamos getUserImage
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Mientras esperas la respuesta
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // Si ocurre un error
                return Text('Error al cargar la imagen');
              } else if (snapshot.hasData) {
                // Si se recibe la imagen correctamente
                final image = snapshot.data!;
                return AddFriendWidget(
                  username: user['nickname'],
                  image: image, // Pasa la imagen cargada
                  onAddFriend: () {
                    print('Agregar a ${user['nickname']}');
                  },
                );
              } else {
                return Text('No se pudo cargar la imagen');
              }
            },
          );
        },
      ),
    );
  }
}
