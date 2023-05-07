import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  Profile({
    Key? key,
    required this.username,
    required this.address,
    required this.password,
    required this.phoneNumber,
    required this.usernameId,
  }) : super(key: key);

  String address;
  String password;
  String phoneNumber;
  String usernameId;
  String username;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
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
                    suffixIcon: IconButton(
                      icon: Icon(showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          showConfirmPassword = !showConfirmPassword;
                        });
                      },
                    ),
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
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
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
                                'update_at': DateTime.now(),
                              });
                              prefs.setString(
                                'address',
                                address,
                              );
                              prefs.setString(
                                'phoneNumber',
                                phoneNumber,
                              );

                              prefs.setString(
                                'password',
                                password,
                              );
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
