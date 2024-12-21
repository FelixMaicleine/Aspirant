import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aspirant/provider/theme.dart';
import 'package:http/http.dart' as http;
import 'package:aspirant/models/vegehttp.dart';

class Sayur extends StatefulWidget {
  const Sayur({super.key});

  @override
  State<Sayur> createState() => _SayurState();
}

class _SayurState extends State<Sayur> {
  final String apiKey = 'ab0c8d1ab41c4c178902d2983a1d6229';

  Future<List<Vegetable>> fetchVegetables() async {
    final response1 = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/food/ingredients/search?query=lettuce&apiKey=$apiKey&number=20&offset=0'),
    );
    final response2 = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/food/ingredients/search?query=spinach&apiKey=$apiKey&number=20&offset=0'),
    );
    final response3 = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/food/ingredients/search?query=cabbage&apiKey=$apiKey&number=20&offset=0'),
    );
    if (response1.statusCode == 200 && response2.statusCode == 200 && response2.statusCode == 200) {
    final List jsonResponse1 = json.decode(response1.body)['results'];
    final List jsonResponse2 = json.decode(response2.body)['results'];
    final List jsonResponse3 = json.decode(response3.body)['results'];

    List combinedResults = [...jsonResponse1, ...jsonResponse2, ...jsonResponse3];
    
    return combinedResults.map((data) => Vegetable.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load ingredients');
  }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Aspirant Fresh"),
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Sayuran',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<Vegetable>>(
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
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
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
}

class ProductCard extends StatefulWidget {
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
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _count = 0;

  void _incrementCount() {
    setState(() {
      _count++;
    });
  }

  void _decrementCount() {
    setState(() {
      if (_count > 0) {
        _count--;
      }
    });
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
          Image.network(widget.imageUrl,
              height: 100, width: double.infinity, fit: BoxFit.cover),
          SizedBox(height: 10),
          Text(widget.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,),
          SizedBox(height: 10),
          Text('Rp ${widget.price}',
              style: TextStyle(fontSize: 14, color: Colors.green)),
          // SizedBox(height: 10),
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

