import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  String _location = 'Mendeteksi lokasi...';
  String _username = '';
  double deliveryFee = 10000;
  String selectedPaymentMethod = 'Cash';
  List<String> paymentMethods = ['Cash', 'OVO'];
  double discount = 0;
  String selectedOffer = '';
  List<Map<String, dynamic>> offers = [
    {'label': '10% up to 10000', 'value': 0.1},
    {'label': '20% up to 20000', 'value': 0.2},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _determineLocation();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> _determineLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _location = 'Layanan lokasi tidak aktif';
        });
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _location = 'Izin lokasi ditolak';
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _location = 'Izin lokasi ditolak permanen';
        });
      }
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      if (mounted) {
        setState(() {
          String kota = placemarks[0].subAdministrativeArea ?? '';
          String kecamatan = placemarks[0].locality ?? '';
          String kelurahan = placemarks[0].subLocality ?? '';
          _location = '$kota\n$kecamatan\n$kelurahan';
        });
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _location = 'Gagal mendapatkan lokasi';
      });
    }
  }
}


  double calculateDiscount(double subtotal) {
    if (selectedOffer.isNotEmpty) {
      double offerValue = offers
          .firstWhere((offer) => offer['label'] == selectedOffer)['value'];
      double maxDiscount = subtotal * offerValue;
      return maxDiscount > 10000 ? 10000 : maxDiscount;
    }
    return 0;
  }

  void showNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'Aspirant Fresh',
        body: 'Pesanan Anda sedang diproses...',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aspirant Fresh'),
        centerTitle: true,
      ),
      body: _username.isEmpty
          ? Center(
              child: CircularProgressIndicator()) 
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cart')
                    .doc(_username)
                    .collection('items')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Keranjang Anda kosong.'));
                  }

                  final cartItems = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'name': data['name'],
                      'price': data['price'],
                      'quantity': data['quantity'],
                    };
                  }).toList();

                  double subtotal = cartItems.fold(0,
                      (sum, item) => sum + (item['quantity'] * item['price']));
                  double appliedDiscount = calculateDiscount(subtotal);
                  double total = subtotal + deliveryFee - appliedDiscount;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dari:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('Aspirant Fresh'),
                                SizedBox(height: 10),
                                Text('Ke:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(_location),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Keranjang:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                ...cartItems.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${item['quantity'] ?? 0}x ${item['name'] ?? 'Item tidak diketahui'}'),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove),
                                                onPressed: () async {
                                                  if ((item['quantity'] ?? 0) >
                                                      1) {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('cart')
                                                        .doc(_username)
                                                        .collection('items')
                                                        .doc(item[
                                                            'name']) 
                                                        .update({
                                                      'quantity':
                                                          (item['quantity'] ??
                                                                  0) -
                                                              1
                                                    });
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance
                                                      .collection('cart')
                                                      .doc(_username)
                                                      .collection('items')
                                                      .doc(item[
                                                          'name']) 
                                                      .update({
                                                    'quantity':
                                                        (item['quantity'] ?? 0) +
                                                            1
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          Text(
                                              'Rp ${(item['quantity'] ?? 0) * (item['price'] ?? 0)}'),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pilih Pembayaran',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<String>(
                                  value: selectedPaymentMethod,
                                  isExpanded:
                                      true,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedPaymentMethod =
                                          newValue!; 
                                    });
                                  },
                                  items: paymentMethods
                                      .map<DropdownMenuItem<String>>(
                                          (String method) {
                                    return DropdownMenuItem<String>(
                                      value: method,
                                      child: Text(method),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Pilih Penawaran',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<String>(
                                  value: selectedOffer.isEmpty
                                      ? null
                                      : selectedOffer,
                                  isExpanded: true,
                                  hint: Text('Pilih diskon'),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedOffer = newValue!;
                                      discount = calculateDiscount(subtotal);
                                    });
                                  },
                                  items: offers
                                      .map<DropdownMenuItem<String>>((offer) {
                                    return DropdownMenuItem<String>(
                                      value: offer['label'],
                                      child: Text(offer['label']),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Subtotal:'),
                                    Text('Rp ${subtotal.toStringAsFixed(0)}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Ongkos Kirim:'),
                                    Text('Rp $deliveryFee'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Diskon:',
                                        style: TextStyle(color: Colors.green)),
                                    Text(
                                        '- Rp ${appliedDiscount.toStringAsFixed(0)}',
                                        style: TextStyle(color: Colors.green)),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('Rp ${total.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final cartSnapshot = await FirebaseFirestore
                                        .instance
                                        .collection('cart')
                                        .doc(_username)
                                        .collection('items')
                                        .get();
                    
                                    if (cartSnapshot.docs.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Keranjang Anda kosong.')),
                                      );
                                      return;
                                    }
                                    final cartItems =
                                        cartSnapshot.docs.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      return {
                                        'id': doc.id, 
                                        'nama': data['name'],
                                        'harga': data['price'],
                                        'jumlah': data['quantity'],
                                      };
                                    }).toList();
                    
                                    double subtotal = cartItems.fold(
                                        0,
                                        (sum, item) =>
                                            sum +
                                            (item['jumlah'] * item['harga']));
                                    double appliedDiscount =
                                        calculateDiscount(subtotal);
                                    double total =
                                        subtotal + deliveryFee - appliedDiscount;
                                    await FirebaseFirestore.instance
                                        .collection('sales')
                                        .doc()
                                        .set({
                                      'userId': _username,
                                      'items': cartItems,
                                      'subtotal': subtotal,
                                      'deliveryFee': deliveryFee,
                                      'discount': appliedDiscount,
                                      'total': total,
                                      'timestamp': FieldValue.serverTimestamp(),
                                      'status': 'ongoing',
                                    });
                                    for (var item in cartItems) {
                                      final stokQuery = FirebaseFirestore.instance
                                          .collection('stok')
                                          .where('nama',
                                              isEqualTo: item[
                                                  'nama']); 
                                      final stokSnapshot = await stokQuery.get();
                                      if (stokSnapshot.docs.isNotEmpty) {
                                        final stokData = stokSnapshot.docs.first
                                            .data() as Map<String, dynamic>;
                                        final currentStock =
                                            stokData['stok'] ?? 0;
                                        if (currentStock >= item['jumlah']) {
                                          await stokSnapshot.docs.first.reference
                                              .update({
                                            'stok': currentStock -
                                                item[
                                                    'jumlah'], 
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Stok barang "${item['nama']}" tidak mencukupi.'),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Barang "${item['nama']}" tidak ditemukan di stok.'),
                                          ),
                                        );
                                      }
                                    }
                                    final batch =
                                        FirebaseFirestore.instance.batch();
                                    for (var doc in cartSnapshot.docs) {
                                      batch.delete(doc.reference);
                                    }
                                    await batch.commit();
                                    showNotification();
                                    Navigator.pushNamed(context, '/usrordr');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Pesanan Anda berhasil diproses.'),
                                              backgroundColor: Colors.green,),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Terjadi kesalahan: $e')),
                                    );
                                  }
                                },
                                child: Text(
                                  'Pesan Sekarang',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
