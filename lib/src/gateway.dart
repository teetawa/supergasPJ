import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergas/src/admin/home_admin.dart';
import 'package:supergas/src/user/home.dart';
import 'package:supergas/src/login.dart';

class GateWay extends StatefulWidget {
  const GateWay({Key? key}) : super(key: key);

  @override
  State<GateWay> createState() => _GateWayState();
}

class _GateWayState extends State<GateWay> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserLogin(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == 'notLogin') {
            return const Login();
          }
          if (snapshot.data == 'user') {
            return Home();
          }
          if (snapshot.data == 'admin') {
            return const HomeAdmin();
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }

  _getUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('role') == 'user') {
      return 'user';
    } else if (prefs.getString('role') == 'admin') {
      return 'admin';
    }
    return 'notLogin';
  }
}
