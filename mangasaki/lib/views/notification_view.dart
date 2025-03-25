import 'package:flutter/material.dart';
import 'package:mangasaki/widgets/invitation_widget.dart';

class NotificationView extends StatelessWidget {
  final List<String> friendRequests = ["JohnDoe", "Alice123", "Michael99", "Alexiutu", "pablo pablete","eskebere"]; // Lista de usuarios ficticios

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

  // Versión de escritorio con `GridView` adaptable
  Widget _buildDesktopGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friendRequests.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,  
        crossAxisSpacing: 20,     
        mainAxisSpacing: 20,      // Espaciado vertical entre las tarjetas
        childAspectRatio: 1,      // Mantiene proporción cuadrada
      ),
      itemBuilder: (context, index) {
        return _buildFixedSizeCard(friendRequests[index]);
      },
    );
  }

  // Widget para el cuadrado con tamaño fijo
    Widget _buildFixedSizeCard(String username) {
      return SizedBox(
        width: 250, // Ancho fijo
        height: 400, // Altura fija
        child: InvitationWidgetDesktop(
          username: username,
          profileImageUrl: "https://picsum.photos/200/300?grayscale",
          onAccept: () {
            print("$username Accepted");
          },
          onDecline: () {
            print("$username Declined");
          },
        ),
      );
    }

}
