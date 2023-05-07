import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductAdmin extends StatefulWidget {
  EditProductAdmin({
    Key? key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productDocsId,
  }) : super(key: key);

  String productName;
  String productImage;
  String productPrice;
  String productDocsId;

  @override
  State<EditProductAdmin> createState() => _EditProductAdminState();
}

class _EditProductAdminState extends State<EditProductAdmin> {
  final _formKey = GlobalKey<FormState>();
  String productName = '';
  String productPrice = '';
  String image = '';

  bool loading = false;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขสินค้า'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                image.isEmpty
                    ? Image.memory(
                        base64Decode(widget.productImage),
                        height: 200,
                        gaplessPlayback: true,
                      )
                    : Image.memory(
                        base64Decode(image),
                        height: 200,
                        gaplessPlayback: true,
                      ),
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
                  initialValue: widget.productName,
                  decoration: InputDecoration(
                    focusedBorder: focusedBorder,
                    enabledBorder: enabledBorder,
                    errorBorder: errorBorder,
                    focusedErrorBorder: focusedErrorBorder,
                    icon: const Icon(
                      Icons.abc,
                      color: Colors.black,
                    ),
                    labelText: 'ชื่อสินค้า',
                  ),
                  onSaved: (newValue) {
                    productName = newValue ?? '';
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'กรุณากรอกชื่อสินค้า';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: widget.productPrice,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    focusedBorder: focusedBorder,
                    enabledBorder: enabledBorder,
                    errorBorder: errorBorder,
                    focusedErrorBorder: focusedErrorBorder,
                    icon: const Icon(
                      Icons.price_change,
                      color: Colors.black,
                    ),
                    labelText: 'ราคา',
                  ),
                  onSaved: (newValue) {
                    productPrice = newValue ?? '';
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'กรุณากรอกราคา';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              loading = true;
                            });
                            await FirebaseFirestore.instance
                                .collection('products')
                                .doc(widget.productDocsId)
                                .update({
                              'product_name': productName,
                              'product_price': productPrice,
                              'product_image':
                                  image.isEmpty ? widget.productImage : image,
                              'update_at': DateTime.now(),
                            });
                            setState(() {
                              loading = false;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("แก้ไขสินค้าเรียบร้อยแล้ว"),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'แก้ไขสินค้า',
                          style: TextStyle(fontSize: 32),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
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
