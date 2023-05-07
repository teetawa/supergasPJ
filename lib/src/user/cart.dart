import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergas/src/user/payment.dart';
import 'package:supergas/src/user/profile.dart';

class Cart extends StatefulWidget {
  Cart({Key? key, required this.username}) : super(key: key);

  String username;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
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
        title: const Text('ตะกร้าสินค้า'),
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
          stream: FirebaseFirestore.instance
              .collection('carts')
              .where('username', isEqualTo: widget.username)
              .where('status', isEqualTo: 'รอดำเนินการ')
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data.docs;
              return data.length == 0
                  ? const Center(child: Text('ไม่มีสินค้าในตะกร้า'))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (_, index) {
                          var total = int.parse(data[index]['product_price']) *
                              data[index]['quantity'];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Payment(
                                    productId: data[index].id,
                                    productImage: data[index]['product_image'],
                                    productName: data[index]['product_name'],
                                    productPrice: data[index]['product_price'],
                                    quantity:
                                        data[index]['quantity'].toString(),
                                    totalPrice: total.toString(),
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.memory(
                                    base64Decode(data[index]['product_image']),
                                    width: width * 0.2,
                                    gaplessPlayback: true,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data[index]['product_name'],
                                        style: TextStyle(
                                          fontSize: 24,
                                          shadows: shadow,
                                        ),
                                      ),
                                      Text(
                                        'ราคา ${data[index]['product_price']}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          shadows: shadow,
                                        ),
                                      ),
                                      Text(
                                        'จำนวน ${data[index]['quantity'].toString()} ชิ้น',
                                        style: TextStyle(
                                          fontSize: 24,
                                          shadows: shadow,
                                        ),
                                      ),
                                      Text(
                                        'ราคารวม ${total.toString()} บาท',
                                        style: TextStyle(
                                          fontSize: 24,
                                          shadows: shadow,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('carts')
                                          .doc(data[index].id)
                                          .delete();
                                    },
                                    icon: const Icon(Icons.delete),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
            }
            return const CircularProgressIndicator();
          },
          
        ),
      ),
    );
    
  }
}
