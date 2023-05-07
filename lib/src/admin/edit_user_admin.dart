import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supergas/src/admin/edit_user_admin_detail.dart';

class EditUserAdmin extends StatefulWidget {
  const EditUserAdmin({Key? key}) : super(key: key);

  @override
  State<EditUserAdmin> createState() => _EditUserAdminState();
}

class _EditUserAdminState extends State<EditUserAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลสมาชิก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: ((BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserAdminDetail(
                            username: data[index]['username'],
                            address: data[index]['address'],
                            password: data[index]['password'],
                            phoneNumber: data[index]['phoneNumber'],
                            usernameId: data[index].id,
                            role: data[index]['role'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Text(
                            'username : ${data[index]['username']}',
                            style: const TextStyle(fontSize: 24),
                          ),
                          Text(
                            'role : ${data[index]['role']}',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const CircularProgressIndicator();
          }),
        ),
      ),
    );
  }
}
