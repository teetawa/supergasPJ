import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageOrderAdmin extends StatefulWidget {
  const ManageOrderAdmin({super.key});

  @override
  State<ManageOrderAdmin> createState() => _ManageOrderAdminState();
}

class _ManageOrderAdminState extends State<ManageOrderAdmin>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('จัดการคำสั่งซื้อ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: 'รอยืนยัน',
            ),
            Tab(
              text: 'ยืนยัน',
            ),
            Tab(
              text: 'กำลังไปส่ง',
            ),
            Tab(
              text: 'เสร็จสิ้น',
            ),
            Tab(
              text: 'ล้มเหลว',
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .where('status', isEqualTo: 'รอยืนยันการชำระเงิน')
                  .snapshots(),
              builder: ((BuildContext _, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data.docs;
                  return data.length == 0
                      ? const Center(child: Text('ไม่มีสินค้าในตะกร้า'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (_, index) {
                            var total =
                                int.parse(data[index]['product_price']) *
                                    data[index]['quantity'];
                            return Card(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.memory(
                                        base64Decode(
                                            data[index]['product_image']),
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
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Image.memory(
                                        base64Decode(data[index]['slip']),
                                        width: width * 0.5,
                                        gaplessPlayback: true,
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('carts')
                                                  .doc(data[index].id)
                                                  .update({
                                                'status': 'ยืนยันการชำระเงิน',
                                                'update_at': DateTime.now(),
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          IconButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('carts')
                                                  .doc(data[index].id)
                                                  .update({
                                                'status': 'ชำระเงินล้มเหลว',
                                                'update_at': DateTime.now(),
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                          )
                                        ],
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
              }),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .where('status', isEqualTo: 'ยืนยันการชำระเงิน')
                  .snapshots(),
              builder: ((BuildContext _, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data.docs;
                  return data.length == 0
                      ? const Center(child: Text('ไม่มีสินค้าในตะกร้า'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (_, index) {
                            var total =
                                int.parse(data[index]['product_price']) *
                                    data[index]['quantity'];
                            return Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.memory(
                                        base64Decode(
                                            data[index]['product_image']),
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
                                    ],
                                  ),
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ชื่อคนสั่ง ${data[index]['username']}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            shadows: shadow,
                                          ),
                                        ),
                                        Text(
                                          'ที่อยู่ ${data[index]['user_address']}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            shadows: shadow,
                                          ),
                                        ),
                                        Text(
                                          'เบอร์โทร ${data[index]['user_phone']}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            shadows: shadow,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'ดำเนินการส่งสินค้า',
                                              style: TextStyle(
                                                fontSize: 24,
                                                shadows: shadow,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection('carts')
                                                    .doc(data[index].id)
                                                    .update({
                                                  'status': 'กำลังไปส่ง',
                                                  'update_at': DateTime.now(),
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                }
                return const CircularProgressIndicator();
              }),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .where('status', isEqualTo: 'กำลังไปส่ง')
                  .snapshots(),
              builder: ((BuildContext _, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data.docs;
                  return data.length == 0
                      ? const Center(child: Text('ไม่มีสินค้าในตะกร้า'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (_, index) {
                            var total =
                                int.parse(data[index]['product_price']) *
                                    data[index]['quantity'];
                            return Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.memory(
                                        base64Decode(
                                            data[index]['product_image']),
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
                                    ],
                                  ),
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ชื่อคนสั่ง ${data[index]['username']}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            shadows: shadow,
                                          ),
                                        ),
                                        Text(
                                          'ที่อยู่ ${data[index]['user_address']}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            shadows: shadow,
                                          ),
                                        ),
                                        Text(
                                          'เบอร์โทร ${data[index]['user_phone']}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            shadows: shadow,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'จัดส่งเสร็จ',
                                              style: TextStyle(
                                                fontSize: 24,
                                                shadows: shadow,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection('carts')
                                                    .doc(data[index].id)
                                                    .update({
                                                  'status': 'เสร็จสิ้น',
                                                  'update_at': DateTime.now(),
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                }
                return const CircularProgressIndicator();
              }),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .where('status', isEqualTo: 'เสร็จสิ้น')
                  .snapshots(),
              builder: ((BuildContext _, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data.docs;
                  return data.length == 0
                      ? const Center(child: Text('ไม่มีสินค้าในตะกร้า'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (_, index) {
                            var total =
                                int.parse(data[index]['product_price']) *
                                    data[index]['quantity'];
                            return Card(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.memory(
                                        base64Decode(
                                            data[index]['product_image']),
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
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Image.memory(
                                        base64Decode(data[index]['slip']),
                                        width: width * 0.5,
                                        gaplessPlayback: true,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        );
                }
                return const CircularProgressIndicator();
              }),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('carts')
                  .where('status', isEqualTo: 'การชำระเงินล้มเหลว')
                  .snapshots(),
              builder: ((BuildContext _, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data.docs;
                  return data.length == 0
                      ? const Center(child: Text('ไม่มีสินค้าในตะกร้า'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (_, index) {
                            var total =
                                int.parse(data[index]['product_price']) *
                                    data[index]['quantity'];
                            return Card(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.memory(
                                        base64Decode(
                                            data[index]['product_image']),
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
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Image.memory(
                                        base64Decode(data[index]['slip']),
                                        width: width * 0.5,
                                        gaplessPlayback: true,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        );
                }
                return const CircularProgressIndicator();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
