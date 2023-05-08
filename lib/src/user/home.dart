import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergas/src/user/cart.dart';
import 'package:supergas/src/user/order.dart';
import 'package:supergas/src/user/product.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  Map<String, dynamic> adminData = {};
  String myAddress = "";

  @override
  void initState() {
    super.initState();
    setupMyAddress();
    setupAdminLocation();
  }

  setupMyAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? address = prefs.getString("address");

    setState(() {
      myAddress = address ?? "";
    });
  }

  setupAdminLocation() async {
    QuerySnapshot raw = await FirebaseFirestore.instance.collection('users').get();
    List<dynamic> data = raw.docs.map((e) => e.data()).toList();
    adminData = data.firstWhere((e) => e['role'] == 'admin');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUsername(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: _selectedIndex == 0
                ? Product(adminData: adminData, myAddress: myAddress)
                : _selectedIndex == 1
                    ? Cart(
                        username: snapshot.data.toString(),
                      )
                    : Order(
                        username: snapshot.data.toString(),
                      ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'หน้าหลัก',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'ตะกร้าสินค้า',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'คำสั่งซื้อสินค้า',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Color.fromARGB(255, 0, 0, 0),
              onTap: (int index) {
                setState(
                  () {
                    _selectedIndex = index;
                  },
                );
              },
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
        return const CircularProgressIndicator();
      },
    );
  }

  _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}
