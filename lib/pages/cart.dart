import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {

  String _location = 'Mendeteksi lokasi...';

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

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          String kota = placemarks[0].subAdministrativeArea ?? '';
          String kecamatan = placemarks[0].locality ?? '';
          String kelurahan = placemarks[0].subLocality ?? '';
          _location = '$kota\n$kecamatan\n$kelurahan';
        });
      }
    } catch (e) {
      setState(() {
        _location = 'Gagal mendapatkan lokasi';
      });
    }
  }
@override
  void initState() {
    super.initState();
    _determineLocation();
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

  List<Map<String, dynamic>> cartItems = [
    {'name': 'Bayam', 'quantity': 1, 'price': 5000},
    {'name': 'Kangkung', 'quantity': 1, 'price': 5000},
    {'name': 'Sawi', 'quantity': 1, 'price': 5000},
  ];

  double deliveryFee = 10000;
  double discount = 0;
  String selectedPaymentMethod = 'Cash';
  List<String> paymentMethods = ['Cash', 'OVO'];
  List<Map<String, dynamic>> offers = [
    {'label': '10% up to 10000', 'value': 0.1},
    {'label': '20% up to 20000', 'value': 0.2},
  ];
  String selectedOffer = '';

  double calculateSubtotal() {
    return cartItems.fold(
        0, (sum, item) => sum + (item['quantity'] * item['price']));
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

  double calculateTotal() {
    double subtotal = calculateSubtotal();
    double appliedDiscount = calculateDiscount(subtotal);
    return subtotal + deliveryFee - appliedDiscount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Anda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Aspirant Fresh'),
                    SizedBox(height: 10),
                    Text('Ke:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Text('Keranjang:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...cartItems.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item['quantity']}x ${item['name']}'),
                              Text('Rp ${item['quantity'] * item['price']}'),
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
                    Text('Metode Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: selectedPaymentMethod,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPaymentMethod = newValue!;
                        });
                      },
                      items: paymentMethods
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
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
                    Text('Pilih Penawaran',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: selectedOffer.isEmpty ? null : selectedOffer,
                      isExpanded: true,
                      hint: Text('Pilih diskon'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOffer = newValue!;
                          discount = calculateDiscount(calculateSubtotal());
                        });
                      },
                      items: offers.map<DropdownMenuItem<String>>((offer) {
                        return DropdownMenuItem<String>(
                          value: offer['label'],
                          child: Text(offer['label']),
                        );
                      }).toList(),
                    ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:'),
                        Text('Rp ${calculateSubtotal().toStringAsFixed(0)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ongkos Kirim:'),
                        Text('Rp $deliveryFee'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Diskon:', style: TextStyle(color: Colors.green)),
                        Text('- Rp ${discount.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Rp ${calculateTotal().toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pesanan Anda sedang diproses.')),
                  );
                  showNotification();
                  Navigator.pushNamed(context, '/homeuser');
                },
                child: Text('Pesan Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
