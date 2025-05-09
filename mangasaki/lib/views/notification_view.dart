import 'package:flutter/material.dart';
import 'package:mangasaki/widgets/invitation_widget.dart';
import 'dart:typed_data';

import '../connection/api_service.dart';


class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final List<String> friendRequests = ["admin", "client", "Michael99", "Alexiutu", "pablo pablete", "eskebere"];
  Map<String, Uint8List> userImages = {};

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = _isMobile(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 111, 150),
        elevation: 2,
      ),
      body: Container(
        color: const Color.fromARGB(255, 60, 111, 150),
        child: _buildMobileList(),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: friendRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final username = friendRequests[index];
        return FutureBuilder<Uint8List>(
          future: getUserImage(username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Text('Error al cargar la imagen');
            } else if (snapshot.hasData) {
              return InvitationWidget(
                username: username,
                profileImageUrl: snapshot.data!, // Imagen Uint8List
                onAccept: () {
                  print("$username accepted");
                },
                onDecline: () {
                  print("$username declined");
                },
              );
            } else {
              return const Text('No se pudo cargar la imagen');
            }
          },
        );
      },
    );
  }

  Future<Uint8List> getUserImage(String nickname) async {
    if (userImages.containsKey(nickname)) {
      return userImages[nickname]!;
    }
    try {
      final image = await ApiService().getUserImage(nickname);
      setState(() {
        userImages[nickname] = image;
      });
      return image;
    } catch (e) {
      throw Exception("Error al cargar la imagen del usuario");
    }
  }
}
