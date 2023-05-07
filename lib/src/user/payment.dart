import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Payment extends StatefulWidget {
  Payment({
    Key? key,
    required this.productId,
    required this.productImage,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.totalPrice,
  }) : super(key: key);

  String productName;
  String productPrice;
  String productImage;
  String productId;
  String quantity;
  String totalPrice;

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final _formKey = GlobalKey<FormState>();
  String image = '';
  bool loading = false;
  bool imageError = false;
  String username = '';
  String address = '';
  String phoneNumber = '';
  @override
  Widget build(BuildContext context) {
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
          title: const Text('การชำระเงิน'),
        ),
        body: FutureBuilder(
          future: initData(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          'รายละเอียดสินค้า',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('carts')
                                .doc(widget.productId)
                                .snapshots(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                var data = snapshot.data;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.memory(
                                      base64Decode(
                                        data['product_image'].toString(),
                                      ),
                                      width: width * 0.2,
                                      gaplessPlayback: true,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['product_name'],
                                          style: TextStyle(
                                            fontSize: 24,
                                            shadows: shadow,
                                          ),
                                        ),
                                        Text(
                                          'ราคา ${data['product_price']}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            shadows: shadow,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: data['quantity'] > 1
                                                  ? () {
                                                      var quantity =
                                                          data['quantity'] - 1;
                                                      FirebaseFirestore.instance
                                                          .collection('carts')
                                                          .doc(widget.productId)
                                                          .update(
                                                        {'quantity': quantity},
                                                      );
                                                    }
                                                  : null,
                                              icon: const Icon(Icons.remove),
                                            ),
                                            Text(
                                              data['quantity'].toString(),
                                              style: TextStyle(
                                                fontSize: 24,
                                                shadows: shadow,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: data['quantity'] < 3
                                                  ? () {
                                                      var quantity =
                                                          data['quantity'] + 1;
                                                      setState(() {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('carts')
                                                            .doc(widget
                                                                .productId)
                                                            .update(
                                                          {
                                                            'quantity': quantity
                                                          },
                                                        );
                                                      });
                                                    }
                                                  : null,
                                              icon: const Icon(Icons.add),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'ราคารวม ${(int.parse(data['quantity'].toString()) * int.parse(data['product_price'].toString()))} บาท',
                                          style: TextStyle(
                                            fontSize: 24,
                                            shadows: shadow,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ช่องทางการชำระเงิน',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'ธนาคาร กสิกรไทย : 000-000-0000',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Image.network('https://scontent.fcnx4-1.fna.fbcdn.net/v/t1.15752-9/340150388_6004489156313681_4794132119013841684_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=ae9488&_nc_ohc=XCGkcJA_GZAAX-OTEXk&_nc_ht=scontent.fcnx4-1.fna&oh=03_AdShm6j5KZ_2GUNOSSX7M-RvN4S4za0_bzhLTdo4AHgKkQ&oe=646F55C1'),
                        const SizedBox(height: 20),
                        image.isEmpty
                            ? GestureDetector(
                                onTap: () async {
                                  var res = await pickImage();
                                  if (res != null) {
                                    setState(() {
                                      image = res;
                                    });
                                  }
                                },
                                child: Container(
                                  color: Colors.grey[300],
                                  height: 200,
                                  child: const Center(
                                    child: Text('กรุณาใส่รูปภาพ'),
                                  ),
                                ),
                              )
                            : Image.memory(
                                base64Decode(image),
                                height: 200,
                                gaplessPlayback: true,
                              ),
                        if (imageError)
                          const Text(
                            'กรุณาใส่รูปภาพ',
                            style: TextStyle(color: Colors.red),
                          ),
                        if (image.isNotEmpty)
                          ElevatedButton(
                            onPressed: () async {
                              var res = await pickImage();
                              if (res != null) {
                                setState(() {
                                  image = res;
                                });
                              }
                            },
                            child: const Text('แก้ไขรูปภาพ'),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: username,
                          decoration: InputDecoration(
                            focusedBorder: focusedBorder,
                            enabledBorder: enabledBorder,
                            errorBorder: errorBorder,
                            focusedErrorBorder: focusedErrorBorder,
                            icon: const Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            labelText: 'Username',
                            enabled: false,
                          ),
                          onSaved: (newValue) {
                            username = newValue ?? '';
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: address,
                          decoration: InputDecoration(
                            focusedBorder: focusedBorder,
                            enabledBorder: enabledBorder,
                            errorBorder: errorBorder,
                            focusedErrorBorder: focusedErrorBorder,
                            icon: const Icon(
                              Icons.map,
                              color: Colors.black,
                            ),
                            labelText: 'Address',
                            enabled: false,
                          ),
                          onSaved: (newValue) {
                            address = newValue ?? '';
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'กรุณากรอก Address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: phoneNumber,
                          decoration: InputDecoration(
                            focusedBorder: focusedBorder,
                            enabledBorder: enabledBorder,
                            errorBorder: errorBorder,
                            focusedErrorBorder: focusedErrorBorder,
                            icon: const Icon(
                              Icons.phone,
                              color: Colors.black,
                            ),
                            labelText: 'Phone Number',
                            enabled: false,
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (newValue) {
                            phoneNumber = newValue ?? '';
                          },
                          maxLength: 10,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'กรุณากรอก Phone Number';
                            } else if (value.length != 10) {
                              return 'กรุณากรอก หมายเลขโทรศัพท์ให้ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () async {
                                  if (image.isEmpty) {
                                    setState(() {
                                      imageError = true;
                                    });
                                  } else {
                                    setState(() {
                                      imageError = false;
                                    });
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      setState(() {
                                        loading = true;
                                      });
                                      await FirebaseFirestore.instance
                                          .collection('carts')
                                          .doc(widget.productId)
                                          .update({
                                        'slip': image,
                                        'user_address': address,
                                        'user_phone': phoneNumber,
                                        'update_at': DateTime.now(),
                                        'status': 'รอยืนยันการชำระเงิน',
                                      });
                                      Dio dio = Dio();
                                      dio.options.contentType =
                                          Headers.formUrlEncodedContentType;

                                      await dio.post(
                                        'https://notify-api.line.me/api/notify',
                                        data: FormData.fromMap({
                                          'message':
                                              'มีคำสั่งซื้อใหม่ กรุณาเข้าแอปเพื่อตรวจสอบ',
                                        }),
                                        options: Options(
                                          headers: {
                                            "authorization":
                                                "Bearer bjYhCo9acGjVH30GmRH1dqJYCb8CJ7PsPYLQb4WWKKD"
                                          },
                                          contentType:
                                              Headers.formUrlEncodedContentType,
                                        ),
                                      );
                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "ยืนยันการชำระเงินเรียบร้อยแล้ว"),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text('ยืนยันการชำระเงิน'),
                              )
                      ],
                    ),
                  ),
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ));
  }

  initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    address = prefs.getString('address') ?? '';
    phoneNumber = prefs.getString('phoneNumber') ?? '';
    return 'Success';
  }

  pickImage() async {
    final ImagePicker picker = ImagePicker();
    var image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
    );
    if (image != null) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return base64Image;
    } else {
      return null;
    }
  }
}
