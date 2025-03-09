import 'package:flutter/material.dart';
import 'package:mangasaki/widgets/invitation_widget.dart';

class NotificationView extends StatelessWidget {
  final List<String> friendRequests = ["JohnDoe", "Alice123", "Michael99"]; // Lista de usuarios ficticios

  NotificationView({Key? key}) : super(key: key);

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
        child: isMobile
            ? _buildMobileList()
            : _buildDesktopGrid(), // Cambia entre lista y grid según el dispositivo
      ),
    );
  }

  // Versión móvil con `ListView`
  Widget _buildMobileList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: friendRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return InvitationWidgetMobile(
          username: friendRequests[index],
          onAccept: () {
            print("${friendRequests[index]} accepted");
          },
          onDecline: () {
            print("${friendRequests[index]} declined");
          },
        );
      },
    );
  }

  //Versión de escritorio con `GridView`
  Widget _buildDesktopGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friendRequests.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // columnas en escritorio
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1, // Mantiene proporción cuadrada
      ),
      itemBuilder: (context, index) {
        return InvitationWidgetDesktop(
          username: friendRequests[index],
          profileImageUrl: "https://picsum.photos/200/300?grayscale", // Usa una imagen local en assets
          onAccept: () {
            print("${friendRequests[index]} accepted");
          },
          onDecline: () {
            print("${friendRequests[index]} declined");
          },
        );
      },
    );
  }
}
