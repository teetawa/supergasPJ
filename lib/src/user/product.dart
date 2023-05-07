import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergas/src/user/product_detail.dart';
import 'package:supergas/src/user/profile.dart';

class Product extends StatelessWidget {
  const Product({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var shadow = <Shadow>[
      const Shadow(
        offset: Offset(0.0, 0.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      const Shadow(
        offset: Offset(0.0, 0.0),
        blurRadius: 8.0,
        color: Colors.red,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('สินค้า'),
        actions: [
          IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      address: prefs.getString('address') ?? '',
                      username: prefs.getString('username') ?? '',
                      password: prefs.getString('password') ?? '',
                      phoneNumber: prefs.getString('phoneNumber') ?? '',
                      usernameId: prefs.getString('usernameId') ?? '',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(
                          productName: data[index]['product_name'],
                          productImage: data[index]['product_image'],
                          productPrice: data[index]['product_price'],
                        ),
                      ),
                    ),
                    child: Card(
                      child: Row(
                        children: [
                          Image.memory(
                            base64Decode(data[index]['product_image']),
                            width: width * 0.2,
                            gaplessPlayback: true,
                          ),
                          Text(
                            data[index]['product_name'],
                            style: TextStyle(
                              fontSize: 28,
                              shadows: shadow,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
