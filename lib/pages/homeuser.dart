import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final List<String> productNames = [
    'Bayam',
    'Kangkung',
    'Wortel',
    'Bawang Putih',
    'Kentang'
  ];

  final List<int> productPrices = [5000, 6000, 7000, 8000, 10000];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
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
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Kategori Sayur',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
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
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Produk Unggulan',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 3.3 / 4,
                ),
                itemCount: productNames.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    name: productNames[index],
                    imageUrl:
                        'https://th.bing.com/th/id/OIP.mgFUu-953G584Vu5GfF5-gAAAA?rs=1&pid=ImgDetMain',
                    price: productPrices[index],
                  );
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

class ProductCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int price;

  const ProductCard(
      {super.key,
      required this.name,
      required this.imageUrl,
      required this.price});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 0;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: isDarkMode ? Colors.green[900] : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.imageUrl,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10),
          Text(
            widget.name,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Rp ${widget.price}',
            style: TextStyle(fontSize: 14.0, color: Colors.green),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: _decrementQuantity,
                color: Colors.red,
              ),
              Text(
                '$_quantity',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _incrementQuantity,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
