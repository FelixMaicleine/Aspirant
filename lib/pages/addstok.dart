import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aspirant/models/modelstock.dart';

class AddStok extends StatefulWidget {
  const AddStok({super.key});

  @override
  State<AddStok> createState() => _AddStokState();
}

class _AddStokState extends State<AddStok> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  File? _imageFile;

  Future pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToStorage(String nama) async {
    if (_imageFile == null) return null;
    final storageRef =
        FirebaseStorage.instance.ref().child("stok_images/$nama.jpg");
    await storageRef.putFile(_imageFile!);
    return await storageRef.getDownloadURL();
  }

  Future addEvent() async {
    final db = FirebaseFirestore.instance;

    final imageUrl = await uploadImageToStorage(namaController.text.trim());

    StokModel insertData = StokModel(
      nama: namaController.text.trim(),
      harga: int.tryParse(hargaController.text.trim()) ?? 0,
      stok: int.tryParse(stokController.text.trim()) ?? 0,
      imageUrl: imageUrl ?? '',
    );

    await db.collection("stok").add(insertData.toMap());
    namaController.clear();
    hargaController.clear();
    stokController.clear();
    setState(() {
      _imageFile = null;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aspirant Fresh"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: stokController,
                decoration: const InputDecoration(labelText: "Stok"),
                keyboardType: TextInputType.number,
              ),
            ),
            _imageFile != null
                ? Image.file(_imageFile!, height: 150)
                : const Text("No image selected"),
            TextButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pilih Gambar"),
            ),
            ElevatedButton(
              onPressed: addEvent,
              child: const Text("Add Data"),
            ),
          ],
        ),
      ),
    );
  }
}
