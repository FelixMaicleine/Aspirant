import 'package:aspirant/models/modelstock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {

  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdVisible = true;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  String _username = '';
  String _location = 'Mendeteksi lokasi...';
  final String apiKey = 'ab0c8d1ab41c4c178902d2983a1d6229';
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadUsername();
    _determineLocation();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', 
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );

    _bannerAd.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', 
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          _interstitialAd?.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load interstitial ad: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAd(VoidCallback onAdClosed) {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _loadInterstitialAd();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _loadInterstitialAd();
          onAdClosed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onAdClosed();
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _interstitialAd?.dispose();
    super.dispose();
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


  Future<List<StokModel>> fetchStok() async {
    final snapshot = await FirebaseFirestore.instance.collection('stok').get();
    return snapshot.docs.map((doc) {
      return StokModel(
        nama: doc['nama'],
        harga: doc['harga'],
        imageUrl: doc['imageUrl'], stok: doc['stok'], 
      );
    }).toList();
  }


  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('roleId');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    analytics.logScreenView(
      screenName: 'HomeUser',
      screenClass: 'HomeUser',
    );
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Aspirant Fresh"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Container(
                      height: 242,
                      child: DrawerHeader(
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.green.shade900 : Colors.green,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 40.0,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person,
                                  size: 50.0, color: Colors.green),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _username,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              _location,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text(AppLocalizations.of(context)!.profil),
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text(AppLocalizations.of(context)!.seting),
                      onTap: () {
                        Navigator.pushNamed(context, '/setting');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.eco),
                      title: Text(AppLocalizations.of(context)!.seting),
                      onTap: () {
                        Navigator.pushNamed(context, '/sayur');
                      },
                    ),ListTile(
                      leading: Icon(Icons.apple),
                      title: Text(AppLocalizations.of(context)!.seting),
                      onTap: () {
                        Navigator.pushNamed(context, '/buah');
                      },
                    ),ListTile(
                      leading: Icon(Icons.grass),
                      title: Text(AppLocalizations.of(context)!.seting),
                      onTap: () {
                        Navigator.pushNamed(context, '/rempah');
                      },
                    ),ListTile(
                      leading: Icon(Icons.other_houses),
                      title: Text(AppLocalizations.of(context)!.seting),
                      onTap: () {
                        Navigator.pushNamed(context, '/other');
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text(AppLocalizations.of(context)!.logout),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPromoBanner(),
                buildCategorySection(),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    AppLocalizations.of(context)!.unggul,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<StokModel>>(
                  future: fetchStok(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data found'));
                    } else {
                      return GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.8 / 4,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final stok = snapshot.data![index];
                          return ProductCard(
                            name: stok.nama,
                            imageUrl:
                                stok.imageUrl ?? '', 
                            price: stok.harga,
                            stok: stok.stok,
                          );
                        },
                      );
                    }
                  },
                )
              ],
            ),
          ),
          if (_isAdVisible && _isAdLoaded)
            Positioned(
              top: 5,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  Container(
                    height: _bannerAd.size.height.toDouble(),
                    width: MediaQuery.of(context).size.width,
                    child: AdWidget(ad: _bannerAd),
                  ),
                  Positioned(
                    top: 0,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAdVisible = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cart');
        },
        backgroundColor: Colors.green,
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildPromoBanner() {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(20.0),
      height: 120.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.orange,
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.promo,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 5),
          Container(
            height: 100,
            width: 100,
            child: Image.network(
              'https://media.istockphoto.com/id/1004057556/id/vektor/label-diskon-20.jpg?s=170667a&w=0&k=20&c=EeVttjS9XkDG34U147S0xyVpvNdJj79PZOpMZLDjfJg=',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategorySection() {
    return Container(
      height: 100.0,
      margin: EdgeInsets.all(10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          categoryCard(AppLocalizations.of(context)!.sayur, Icons.eco, () {
            Navigator.pushNamed(context, '/sayur');
          }),
          categoryCard(AppLocalizations.of(context)!.buah, Icons.apple, () {
            Navigator.pushNamed(context, '/buah');
          }),
          categoryCard(AppLocalizations.of(context)!.rempah, Icons.grass, () {
            Navigator.pushNamed(context, '/rempah');
          }),
          categoryCard(AppLocalizations.of(context)!.lain, Icons.other_houses, () {
            Navigator.pushNamed(context, '/other');
          }),
        ],
      ),
    );
  }

  Widget categoryCard(String title, IconData icon, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () async {
        await analytics.logEvent(
          name: 'category_clicked',
          parameters: {
            'category_name': title,
          },
        );
        _showInterstitialAd(onTap);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        width: 100.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isDarkMode ? Colors.green[900] : Colors.lightGreenAccent[400],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: Colors.green),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int price;
  final int stok;

  const ProductCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.stok,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _count = 0;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> _addToCart() async {
    if (_username.isEmpty) return;

    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(_username)
        .collection('items')
        .doc(widget.name);

    final cartData = {
      'name': widget.name,
      'price': widget.price,
      'quantity': _count,
    };

    await cartRef.set(cartData);
  }

  Future<void> _removeFromCart() async {
    if (_username.isEmpty) return;

    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(_username)
        .collection('items')
        .doc(widget.name);

    await cartRef.delete();
  }

  void _incrementCount() async {
    setState(() {
      _count++;
    });

    if (_count == 1) {
      await _addToCart();
    } else {
      await _addToCart();
    }
  }

  void _decrementCount() async {
    if (_count > 0) {
      setState(() {
        _count--;
      });

      if (_count == 0) {
        await _removeFromCart();
      } else {
        await _addToCart();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDarkMode ? Colors.green[900] : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.imageUrl,
            height: 150,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image, size: 100),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Stok: ${widget.stok}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('Rp ${widget.price}',
              style: TextStyle(fontSize: 14, color: Colors.green)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: _decrementCount,
              ),
              Text(
                '$_count',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _incrementCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

