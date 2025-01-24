import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Sales extends StatefulWidget {
  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  String searchUserId = ""; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aspirant Fresh"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchUserId = value.trim(); 
                });
              },
              decoration: InputDecoration(
                hintText: "Search by User ID",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sales')
                  .where('status', isEqualTo: 'done')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No sales data available."));
                }

                final allSales = snapshot.data!.docs;
                final filteredSales = searchUserId.isEmpty
                    ? allSales
                    : allSales.where((doc) {
                        final userId = doc['userId']?.toString() ?? "";
                        return userId.contains(searchUserId);
                      }).toList();

                if (filteredSales.isEmpty) {
                  return Center(
                    child: Text("No results for User ID \"$searchUserId\"."),
                  );
                }

                return ListView.builder(
                  itemCount: filteredSales.length,
                  itemBuilder: (context, index) {
                    final sale = filteredSales[index];
                    final items = (sale['items'] as List).cast<Map<String, dynamic>>();
                    final timestamp = sale['timestamp']?.toDate();
                    final formattedDate = timestamp != null
                        ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp)
                        : "Unknown Date";

                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order ID: ${sale.id}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "User ID: ${sale['userId']}",
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Date: $formattedDate",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Divider(),
                            Column(
                              children: items.map((item) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${item['nama']} x${item['jumlah']}"),
                                    Text("Rp${(item['harga'] * item['jumlah']).toStringAsFixed(0)}"),
                                  ],
                                );
                              }).toList(),
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Subtotal:"),
                                Text("Rp${sale['subtotal']}"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Delivery Fee:"),
                                Text("Rp${sale['deliveryFee']}"),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Discount:"),
                                Text("-Rp${sale['discount']}"),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Rp${sale['total']}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
