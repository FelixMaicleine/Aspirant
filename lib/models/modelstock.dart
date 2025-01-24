import 'package:cloud_firestore/cloud_firestore.dart';

class StokModel {
  String? id;
  String nama;
  int harga;
  int stok;
  String? imageUrl; 

  StokModel({
    this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    this.imageUrl, 
  });

  factory StokModel.fromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StokModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      harga: (data['harga'] ?? 0).toInt(),
      stok: (data['stok'] ?? 0).toInt(),
      imageUrl: data['imageUrl'], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'imageUrl': imageUrl, 
    };
  }
}
