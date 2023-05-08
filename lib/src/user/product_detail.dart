import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetail extends StatefulWidget {
  ProductDetail({
    Key? key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    this.over = false,
  }) : super(key: key);

  String productName;
  String productImage;
  String productPrice;
  bool over;

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int quantity = 1;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    widget.over;

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Detail"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Image.memory(
            base64Decode(widget.productImage),
            width: width * 0.4,
            gaplessPlayback: true,
          ),
          const SizedBox(height: 16),
          Text(
            widget.productName,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 16),
          Text(
            'ราคา ${widget.productPrice} บาท',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () {
                        setState(() {
                          quantity--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(fontSize: 32),
              ),
              IconButton(
                onPressed: quantity < 3
                    ? () {
                        setState(() {
                          quantity++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const Text(
            'จำกัดการซื้อที่ 3 ถัง',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: widget.over
                        ? null
                        : () async {
                            setState(() {
                              loading = true;
                            });
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            FirebaseFirestore.instance.collection('carts').add({
                              'product_name': widget.productName,
                              'product_price': widget.productPrice,
                              'product_image': widget.productImage,
                              'quantity': quantity,
                              'username': prefs.getString('username'),
                              'creat_at': DateTime.now(),
                              'update_at': DateTime.now(),
                              'status': "รอดำเนินการ",
                              'slip': '',
                              'user_address': '',
                              'user_phone': '',
                            });
                            setState(() {
                              loading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "ทำการสั่งซื้อเรียบร้อยแล้ว",
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'ทำการสั่งซื้อ',
                            style: TextStyle(fontSize: 28),
                          ),
                          Icon(
                            Icons.shopping_cart,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
