import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OngoingOrderPage extends StatefulWidget {
  @override
  _OngoingOrderPageState createState() => _OngoingOrderPageState();
}

class _OngoingOrderPageState extends State<OngoingOrderPage> {
  String? _username;
  String _location = 'Mendeteksi lokasi...';
  LatLng? _currentPosition;
  // ignore: unused_field
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final LatLng _mikroskilLocation = LatLng(3.587474, 458.690729); 
  final LatLng _titikpusat = LatLng(3.584213, 458.677219); 

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _determineLocation();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
    });
  }

  Future<void> _determineLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = 'Layanan lokasi tidak aktif';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = 'Izin lokasi ditolak';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = 'Izin lokasi ditolak permanen';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _currentPosition = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String kota = placemarks[0].subAdministrativeArea ?? '';
        String kecamatan = placemarks[0].locality ?? '';
        String kelurahan = placemarks[0].subLocality ?? '';
        _location = '$kota\n$kecamatan\n$kelurahan';
      }

      await _getRoute(_mikroskilLocation, _currentPosition!);
    } catch (e) {
      setState(() {
        _location = 'Gagal mendapatkan lokasi';
      });
    }
  }

  Future<void> _getRoute(LatLng origin, LatLng destination) async {
    final apiKey = 'AIzaSyCf_FCwYFXaitbH4Nmnx7lJfZ7kYoD5IYs'; 
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      final points =
          data['routes'][0]['overview_polyline']['points'] as String;
      final List<LatLng> routeCoords = _decodePolyline(points);

      setState(() {
        _markers = {
          Marker(
            markerId: MarkerId("mikroskil"),
            position: origin,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: "Universitas Mikroskil"),
          ),
          Marker(
            markerId: MarkerId("user"),
            position: destination,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: "Lokasi Anda"),
          ),
        };

        _polylines = {
          Polyline(
            polylineId: PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: routeCoords,
          )
        };
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<void> markOrderAsDone(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('sales')
          .doc(docId)
          .update({'status': 'done'});
      Navigator.pushReplacementNamed(context, '/homeuser');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_username == null || _currentPosition == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Aspirant Fresh")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Aspirant Fresh"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/homeuser'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sales')
            .where('status', isEqualTo: 'ongoing')
            .where('userId', isEqualTo: _username)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Tidak ada pesanan yang sedang berlangsung.',
                  style: TextStyle(fontSize: 16)),
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
                child: GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _titikpusat,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    children: [
                      Card(
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
                                      fontWeight: FontWeight.bold),
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
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Aspirant Fresh'),
                              SizedBox(height: 10),
                              Text('Ke:',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                              Text("Informasi Pesanan",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Divider(),
                              Text("Daftar Barang:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Column(
                                children: items.map((item) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("x${item['jumlah']} ${item['nama']}"),
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
