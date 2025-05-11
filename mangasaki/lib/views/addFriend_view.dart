import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mangasaki/widgets/addFriend_widget.dart';
import 'package:provider/provider.dart';
import '../connection/api_service.dart';
import '../connection/app_data.dart';
import '../connection/utils_websockets.dart';
import 'login_view.dart';

class AddFriendView extends StatefulWidget {
  final String letters;

  const AddFriendView({Key? key, required this.letters}) : super(key: key);

  @override
  _AddFriendViewState createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<AddFriendView> {
  Map<String, dynamic> users = {};
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
        users = result;
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

  Future<Map<String, dynamic>> getUserInfo(String nickname) async {
    try {
      final id = await ApiService().getUserInfo(nickname);
      return id;
    } catch (e) {
      throw Exception("Error al cargar el ID del usuario");
    }
  }


  @override
  Widget build(BuildContext context) {
    final List<dynamic> userList = users['data'] ?? [];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 60, 111, 150),
      appBar: AppBar(
        title: const Text("Add friends", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refrescar',
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchUsers(widget.letters); // Vuelve a cargar los usuarios
            },
          ),
        ],
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
                  onAddFriend: () async {
                    // Obtener el ID del usuario al que deseas agregar
                    final targetUsername = user['nickname'];

                    final usuario = await ApiService().getUserInfo(LoginScreen.username);
                    final fromId = usuario["resultat"]["id"];

                    // Crear un mapa con los datos del mensaje
                    Map<String, dynamic> messageData = {
                      "type": "friend_request_notification",
                      "sender_user_id": fromId,
                      "receiver_username": targetUsername,
                    };

                    // Convertir el mapa a una cadena JSON
                    String messageJson = jsonEncode(messageData);
                    final appData = Provider.of<AppData>(context, listen: false);

                    // Enviar el mensaje JSON a través de WebSocket como una cadena
                    appData.sendMessage(messageJson);

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
