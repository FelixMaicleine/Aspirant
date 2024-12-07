import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aspirant/models/eventmodel.dart';

class Stok extends StatefulWidget {
  const Stok({super.key});

  @override
  State<Stok> createState() => _StokState();
}

class _StokState extends State<Stok> {
  String searchQuery = ''; 

  Stream<List<EventModel>> getEventStream() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return db.collection("event").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromDocSnapshot(doc)).toList();
    });
  }

  Future deleteEvent(String docId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("event").doc(docId).delete();
  }

  Future updateEvent(EventModel event) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("event").doc(event.id).update(event.toMap());
  }

  void showEditDialog(EventModel event) {
    final TextEditingController editNamaController =
        TextEditingController(text: event.nama);
    final TextEditingController editHargaController =
        TextEditingController(text: event.harga);
    final TextEditingController editStokController =
        TextEditingController(text: event.stok);

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
              decoration: const InputDecoration(labelText: "Harga"),
            ),
            TextField(
              controller: editStokController,
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
              event.nama = editNamaController.text.trim();
              event.harga = editHargaController.text.trim();
              event.stok = editStokController.text.trim();
              updateEvent(event);
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
        title: const Text("Database Stok"),
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
              child: StreamBuilder<List<EventModel>>(
                stream: getEventStream(),
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

                  List<EventModel> filteredEvents = snapshot.data!
                      .where((event) =>
                          event.nama
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                      .toList();
                  filteredEvents.sort((a, b) => a.nama.compareTo(b.nama));

                  return ListView.builder(
  itemCount: filteredEvents.length,
  itemBuilder: (context, index) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              filteredEvents[index].nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showEditDialog(filteredEvents[index]);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteEvent(filteredEvents[index].id!);
                  },
                ),
              ],
            ),
          ],
        ),
        subtitle: Text(
          "Harga: ${filteredEvents[index].harga.isNotEmpty ? filteredEvents[index].harga : 'N/A'} | "
          "Stok: ${filteredEvents[index].stok.isNotEmpty ? filteredEvents[index].stok : 'N/A'}",
        ),
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
