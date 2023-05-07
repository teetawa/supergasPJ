import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditUserAdminDetail extends StatefulWidget {
  EditUserAdminDetail({
    Key? key,
    required this.username,
    required this.address,
    required this.password,
    required this.phoneNumber,
    required this.usernameId,
    required this.role,
  }) : super(key: key);

  String address;
  String password;
  String phoneNumber;
  String usernameId;
  String role;
  String username;

  @override
  State<EditUserAdminDetail> createState() => _EditUserAdminDetailState();
}

class _EditUserAdminDetailState extends State<EditUserAdminDetail> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String confirmPassword = '';
  String address = '';
  String phoneNumber = '';
  bool passwordNotMatch = false;
  bool showPassword = true;
  bool showConfirmPassword = true;
  bool loading = false;
  String role = '';
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
        title: const Text('แก้ไขข้อมูลสมาชิก'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.username,
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
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'กรุณากรอก Username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: widget.password,
                  obscureText: showPassword,
                  decoration: InputDecoration(
                    focusedBorder: focusedBorder,
                    enabledBorder: enabledBorder,
                    errorBorder: errorBorder,
                    focusedErrorBorder: focusedErrorBorder,
                    icon: const Icon(
                      Icons.password,
                      color: Colors.black,
                    ),
                    labelText: 'Password',
                    enabled: false
                  ),
                  onSaved: (newValue) {
                    password = newValue ?? '';
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'กรุณากรอก Password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: widget.password,
                  obscureText: showConfirmPassword,
                  decoration: InputDecoration(
                    focusedBorder: focusedBorder,
                    enabledBorder: enabledBorder,
                    errorBorder: errorBorder,
                    focusedErrorBorder: focusedErrorBorder,
                    icon: const Icon(
                      Icons.password,
                      color: Colors.black,
                    ),
                    labelText: 'Confirm Password',
                    enabled: false
                  ),
                  onSaved: (newValue) {
                    confirmPassword = newValue ?? '';
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'กรุณากรอก Confirm Password';
                    }
                    return null;
                  },
                ),
                if (passwordNotMatch)
                  const Text(
                    'กรุณาใส่ Password ให้ตรงกัน',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: widget.address,
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
                    enabled: false
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
                  initialValue: widget.phoneNumber,
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
                    enabled: false
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
                CheckboxListTile(
                  title: const Text("สมาชิก"), //    <-- label
                  value: role.isEmpty ? widget.role == 'user' : role == 'user',
                  onChanged: (newValue) {
                    setState(() {
                      role = 'user';
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text("Admin"), //    <-- label
                  value:
                      role.isEmpty ? widget.role == 'admin' : role == 'admin',
                  onChanged: (newValue) {
                    setState(() {
                      role = 'admin';
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
                loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (password == confirmPassword) {
                              setState(() {
                                passwordNotMatch = false;
                                loading = true;
                              });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.usernameId)
                                  .update({
                                'password': password,
                                'address': address,
                                'phoneNumber': phoneNumber,
                                'role': role.isEmpty ? widget.role : role,
                                'update_at': DateTime.now(),
                              });
                              setState(() {
                                loading = false;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("แก้ไขข้อมูลสมาชิกเรียบร้อยแล้ว"),
                              ));
                            } else {
                              setState(() {
                                passwordNotMatch = true;
                              });
                            }
                          }
                        },
                        child: const Text(
                          'แก้ไขข้อมูลสมาชิก',
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
}
