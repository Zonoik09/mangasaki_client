import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:mangasaki/connection/api_service.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  Future<void>? _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras![0], ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(imagePath: pickedFile.path),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${DateTime.now()}.png';
      File(image.path).copy(imagePath);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(imagePath: imagePath),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: Stack(
        children: [
          _controller == null
              ? Center(child: CircularProgressIndicator())
              : FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller!);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón para tomar foto
                  FloatingActionButton(
                    child: Icon(Icons.camera),
                    onPressed: _takePicture,
                  ),
                  SizedBox(width: 20),
                  // Botón para seleccionar imagen de la galería
                  FloatingActionButton(
                    child: Icon(Icons.photo),
                    onPressed: _pickImageFromGallery,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final ApiService apiService = ApiService();

  DisplayPictureScreen({required this.imagePath});

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  bool isLoading = false; // Variable para controlar el estado de carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Picture Taken')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(child: Image.file(File(widget.imagePath))),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Regresa a la cámara
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Cancelar', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () => _sendImageToApi(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  isLoading ? 'Sending...' : 'Send picture',
                  style: TextStyle(color: Colors.white),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  void _sendImageToApi(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Cargar la imagen y convertirla en base64
      File imageFile = File(widget.imagePath);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Enviar la imagen a la API
      Map<String, dynamic> response = await widget.apiService.analyzeManga(base64Image);

      // Mostrar la respuesta
      // Despues se tendra que comparar el type, dependiendo cual sea mostrar una cosa o otra
      final data = response["data"];

      showDialog(
        context: context,
        builder: (context) {
          final String title = data["title"] ?? "No title";
          final String description = data["description"] ?? "No description";
          final String? imageUrl = data["imageLinks"]?["thumbnail"];
          final List<dynamic>? authors = data["authors"];
          final String authorString = authors != null && authors.isNotEmpty
              ? authors.join(", ")
              : "Unknown author";

          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    Center(
                      child: Image.network(imageUrl),
                    ),
                  SizedBox(height: 10),
                  Text("Author(s): $authorString",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(description, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );




      // Mostrar un mensaje de éxito (puedes cambiarlo o personalizarlo)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image successfully sent')),
      );
    } catch (e) {
      // Manejar cualquier error
      print("Error sending image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending image')),
      );
    } finally {
      // Desactivar el indicador de carga
      setState(() {
        isLoading = false;
      });
    }
  }

}
