import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:aspirant/models/vegetable.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  String _username = '';
  final String apiKey = 'c55265c1290c4aca8ed00a4e1f471fae';

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

  Future<List<Vegetable>> fetchVegetables() async {
    final response = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/food/ingredients/search?query=vegetable&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body)['results'];
      return jsonResponse.map((data) => Vegetable.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load vegetables');
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('roleId');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Aspirant Fresh"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              color: isDarkMode ? Colors.black : Colors.yellow,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
          ),
        ],
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
                      height: 190,
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
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPromoBanner(),
            buildCategorySection(),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Produk Unggulan',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 400,
              margin: EdgeInsets.all(10),
              child: FutureBuilder<List<Vegetable>>(
                future: fetchVegetables(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    return GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3.3 / 4,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final vegetable = snapshot.data![index];
                        return ProductCard(
                          name: vegetable.name,
                          imageUrl: vegetable.imageUrl,
                          price: 5000 + (index * 1000),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Keranjang belum tersedia.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
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
              'Promo Spesial! Diskon 20% untuk semua sayur',
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
          categoryCard('Sayur Hijau', Icons.eco),
          categoryCard('Sayur Buah', Icons.apple),
          categoryCard('Sayur Akar', Icons.grass),
          categoryCard('Bumbu Dapur', Icons.local_dining),
          categoryCard('Lainnya', Icons.other_houses),
        ],
      ),
    );
  }

  Widget categoryCard(String title, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Container(
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
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int price;

  const ProductCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl,
              height: 100, width: double.infinity, fit: BoxFit.cover),
          SizedBox(height: 10),
          Text(name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Rp $price',
              style: TextStyle(fontSize: 14, color: Colors.green)),
        ],
      ),
    );
  }
}
