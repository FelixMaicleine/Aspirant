import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class OngoingOrderPage extends StatefulWidget {
  @override
  _OngoingOrderPageState createState() => _OngoingOrderPageState();
}

class _OngoingOrderPageState extends State<OngoingOrderPage> {
  String? _username;
  String _location = 'Mendeteksi lokasi...';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _determineLocation();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username =
          prefs.getString('username'); 
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

  Future<void> markOrderAsDone(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('sales')
          .doc(docId)
          .update({'status': 'done'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan anda telat tiba tepat waktu.'),backgroundColor: Colors.green,),
      );
      showNotification();
      Navigator.pushReplacementNamed(context, '/homeuser');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void showNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'Aspirant Fresh',
        body: 'Pesanan Anda telah tiba tepat waktu.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_username == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Aspirant Fresh"),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Aspirant Fresh"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
                  Navigator.pushNamed(context, '/homeuser');

          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sales')
            .where('status', isEqualTo: 'ongoing')
            .where('userId', isEqualTo: _username)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada pesanan yang sedang berlangsung.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final order = snapshot.data!.docs.first; 
          final data = order.data() as Map<String, dynamic>;
          final items = data['items'] as List<dynamic>;

          return Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        LatLng(3.5951956, 98.6722227), 
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: "com.example.aspirant",
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(3.584010, 98.676830),
                          child: Icon(
                            Icons.delivery_dining,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                        Marker(
                          point: LatLng(3.578600, 98.648300),
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    child: Column(
                      children: [
                        Card(
                          //
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.delivery_dining,
                                    size: 40, color: Colors.green),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Pesanan Anda sedang dalam perjalanan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Informasi Pesanan",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Divider(),
                                Text(
                                  "Daftar Barang:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  children: items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              "x${item['jumlah']} ${item['nama']}"),
                                          Text("Rp ${item['harga']}"),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                Divider(),
                                Text("Subtotal: Rp ${data['subtotal']}"),
                                Text("Diskon: Rp ${data['discount']}"),
                                Text("Ongkir: Rp ${data['deliveryFee']}"),
                                Text("Total: Rp ${data['total']}"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Done Delivery Button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => markOrderAsDone(order.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      "Done Delivery",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
