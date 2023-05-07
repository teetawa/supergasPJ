import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supergas/src/admin/edit_product_admin.dart';

class ProductAdmin extends StatelessWidget {
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
        title: const Text('Product Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'สินค้า',
              style: TextStyle(fontSize: 32),
            ),
            StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (_, index) {
                      return Card(
                        child: Column(
                          children: [
                            Row(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProductAdmin(
                                          productImage: data[index]
                                              ['product_image'],
                                          productName: data[index]
                                              ['product_name'],
                                          productPrice: data[index]
                                              ['product_price'],
                                          productDocsId: data[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showAlertDialog(
                                      context,
                                      documentId: data[index].id,
                                    );
                                  },
                                  icon: const Icon(Icons.delete),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(
    BuildContext context, {
    required String documentId,
  }) {
    Widget cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: const Text(
        "ยกเลิก",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text(
        "ยืนยัน",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(documentId)
            .delete();
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("ยืนยันการลบสินค้า"),
      actions: [
        continueButton,
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
