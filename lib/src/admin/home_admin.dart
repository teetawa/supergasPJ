import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergas/src/admin/add_product_admin.dart';
import 'package:supergas/src/admin/edit_user_admin.dart';
import 'package:supergas/src/admin/manage_order_admin.dart';
import 'package:supergas/src/admin/product_admin.dart';
import 'package:supergas/src/admin/report_order_admin.dart';
import 'package:supergas/src/admin/user_chat_list.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({Key? key}) : super(key: key);

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  String image = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าต่าง Admin'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductAdmin(),
                    ),
                  );
                },
                child: const Text(
                  'เพิ่มสินค้า',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductAdmin(),
                    ),
                  );
                },
                child: const Text(
                  'แก้ไขสินค้า',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageOrderAdmin(),
                    ),
                  );
                },
                child: const Text(
                  'จัดการคำสั่งซื้อ',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditUserAdmin(),
                    ),
                  );
                },
                child: const Text(
                  'จัดการข้อมูลสมาชิก',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportOrderAdmin(),
                    ),
                  );
                },
                child: const Text(
                  'รายงานการสั่งซื้อ',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserChatList(),
                    ),
                  );
                },
                child: const Text(
                  'การติดต่อกับผู้ใช้',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('role');
          prefs.remove('username');
          Phoenix.rebirth(context);
        },
        child: const Icon(Icons.logout),
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
      await Clipboard.setData(ClipboardData(text: base64Image));
      return base64Image;
    } else {
      return null;
    }
  }
}
