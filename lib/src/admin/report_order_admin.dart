import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supergas/src/admin/data_time_extension.dart';

class ReportOrderAdmin extends StatefulWidget {
  const ReportOrderAdmin({Key? key}) : super(key: key);

  @override
  State<ReportOrderAdmin> createState() => _ReportOrderAdminState();
}

class _ReportOrderAdminState extends State<ReportOrderAdmin> {
  final _formKey = GlobalKey<FormState>();
  DateTimeRange selectedDates = DateTimeRange(start: DateTime.now(), end: DateTime.now());

  @override
  Widget build(BuildContext context) {
    var totalprice = 0.0;
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
    var focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green),
    );
    var enabledBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    );
    var errorBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.purple),
    );
    var focusedErrorBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.purple),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายงานคำสั่งซื้อ'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("วันที่ : ${DateFormat('dd MMM yyyy').format(selectedDates.start)}"),
                  const SizedBox(height: 12),
                  Text("ถึง  : ${DateFormat('dd MMM yyyy').format(selectedDates.end)}"),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: const Text("ขอรายงานคำสั่งซื้อ"),
                    onPressed: () async {
                      final DateTimeRange? dateTimeRange = await showDateRangePicker(
                          context: context, firstDate: DateTime(2000), lastDate: DateTime(3000));
                      selectedDates = dateTimeRange ?? selectedDates;
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(
                thickness: 2,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('carts').snapshots(),
                builder: ((BuildContext _, AsyncSnapshot snapshot) {
                  List<dynamic> data = [];
                  if (snapshot.hasData) {
                    var raw = snapshot.data.docs;
                    for (var i = 0; i < raw.length; i++) {
                      var cart = raw[i];
                      var date = cart['update_at'].toDate();
                      var isBetween = DateTimeExtension.isBetween(
                        date,
                        from: selectedDates.start,
                        to: selectedDates.end,
                      );
                      if (isBetween) {
                        data.add(cart);
                      }
                    }
                    return data.isEmpty
                        ? const Center(child: Text('ไม่มีสินค้าในตะกร้า'))
                        : Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'ยอดรวมการสั่งซื้อทั้งหมด : $totalprice บาท',
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: data.length,
                                    itemBuilder: (_, index) {
                                      var total = int.parse(data[index]['product_price']) * data[index]['quantity'];
                                      totalprice = totalprice + total;
                                      return Card(
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Image.memory(
                                                  base64Decode(data[index]['product_image']),
                                                  width: width * 0.2,
                                                  gaplessPlayback: true,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  ),
                                ),
                              ],
                            ),
                          );
                  }
                  return const CircularProgressIndicator();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
