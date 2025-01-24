import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aspirant/models/modelstock.dart';

class Stok extends StatefulWidget {
  const Stok({super.key});

  @override
  State<Stok> createState() => _StokState();
}

class _StokState extends State<Stok> {
  String searchQuery = '';

  Stream<List<StokModel>> getStokStream() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return db.collection("stok").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StokModel.fromDocSnapshot(doc)).toList();
    });
  }

  Future deleteStok(String docId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("stok").doc(docId).delete();
  }

  Future updateStok(StokModel stok) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("stok").doc(stok.id).update(stok.toMap());
  }

  void showEditDialog(StokModel stok) {
    final TextEditingController editNamaController =
        TextEditingController(text: stok.nama);
    final TextEditingController editHargaController =
        TextEditingController(text: stok.harga.toString());
    final TextEditingController editStokController =
        TextEditingController(text: stok.stok.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Data"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editNamaController,
              decoration: const InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: editHargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga"),
            ),
            TextField(
              controller: editStokController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stok"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              stok.nama = editNamaController.text.trim();
              stok.harga = int.tryParse(editHargaController.text.trim()) ?? 0;
              stok.stok = int.tryParse(editStokController.text.trim()) ?? 0;
              updateStok(stok);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aspirant Fresh"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/addstok');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Search by Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<StokModel>>(
                stream: getStokStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No data available"));
                  }

                  List<StokModel> filteredStok = snapshot.data!
                      .where((stok) => stok.nama
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();
                  filteredStok.sort((a, b) => a.nama.compareTo(b.nama));

                  return ListView.builder(
                    itemCount: filteredStok.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                filteredStok[index].nama,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      showEditDialog(filteredStok[index]);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      deleteStok(filteredStok[index].id!);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Text(
                              "Harga: ${filteredStok[index].harga} | Stok: ${filteredStok[index].stok}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
