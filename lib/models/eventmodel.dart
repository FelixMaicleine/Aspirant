import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String? id;
  String nama;
  String harga;
  String stok;

  EventModel({
    this.id,
    required this.nama,
    required this.harga,
    required this.stok,
  });

  factory EventModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      harga: data['harga'] ?? '',
      stok: data['stok'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'harga': harga,
      'stok': stok,
    };
  }
}
