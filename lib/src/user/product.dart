import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergas/src/user/product_detail.dart';
import 'package:supergas/src/user/profile.dart';

import '../util/distance_helper.dart';

class Product extends StatelessWidget {
  final String myAddress;
  final Map<String, dynamic> adminData;
  final VoidCallback onLogout;
  Product({Key? key, required this.adminData, required this.myAddress, required this.onLogout}) : super(key: key);

  double overDistanceKm = 15.0;

  String getCalculate(String address) {
    double lat1 = 0.0;
    double lng1 = 0.0;
    double lat2 = 0.0;
    double lng2 = 0.0;

    if (address.isNotEmpty) {
      lat1 = double.parse(address.split(",")[0]);
      lat2 = double.parse(address.split(",")[1]);
    }

    lat2 = double.parse(myAddress.split(",")[0]);
    lng2 = double.parse(myAddress.split(",")[1]);

    try {
      return calculateDistance(lat1, lng1, lat2, lng2).toStringAsFixed(2);
    } catch (e) {
      return "0";
    }
  }

  overDistance(String km) {
    return double.parse(km) > overDistanceKm;
  }

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
            icon: const Icon(Icons.person),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: onLogout,
          ),
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
                  bool over = overDistance(getCalculate(getSafeValue(adminData, 'address')));

                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(
                          productName: data[index]['product_name'],
                          productImage: data[index]['product_image'],
                          productPrice: data[index]['product_price'],
                          over: over,
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
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[index]['product_name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  shadows: shadow,
                                ),
                              ),
                              Text(
                                "ระยะทาง : ${getCalculate(getSafeValue(adminData, 'address'))} km",
                                style: TextStyle(
                                  fontSize: 16,
                                  shadows: shadow,
                                ),
                              ),
                              if (over)
                                Text(
                                  'เกินระยะทางที่กำหนด',
                                  style: TextStyle(
                                    fontSize: 14,
                                    shadows: shadow,
                                  ),
                                ),
                            ],
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

  String getSafeValue(dynamic data, key) {
    try {
      return data[key];
    } catch (e) {}

    return "";
  }
}
