import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  Future addEvent() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    StokModel insertData = StokModel(
      nama: namaController.text.trim(),
      harga: int.tryParse(hargaController.text.trim()) ?? 0, 
      stok: int.tryParse(stokController.text.trim()) ?? 0,  
    );
    await db.collection("stok").add(insertData.toMap());
    namaController.clear();
    hargaController.clear();
    stokController.clear();
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aspirant Fresh"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
