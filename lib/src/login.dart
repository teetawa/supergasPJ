import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supergas/src/register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  bool showPassword = true;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    var focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    );
    var enabledBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    );
    var errorBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    );
    var focusedErrorBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.network(
                  'https://scontent.fcnx4-1.fna.fbcdn.net/v/t1.15752-9/339568904_988820552501104_2909171993865131025_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=ae9488&_nc_eui2=AeFuMsz-Ul3WgvjAhx0HFEuTKVAF9jrHXIgpUAX2OsdciONNpBV5gn7ucrlTAbI0TqAEtcs7k-A5QTOvIjWCUwQ5&_nc_ohc=ZqxGBS_tBiQAX8hM4LJ&_nc_ht=scontent.fcnx4-1.fna&oh=03_AdSzh0-UnwBNy_-rVFyr9S7ZPnK1dekBkkosWd0x2gFRFA&oe=646A6A70',
                ),
                const Text(
                          'SUPERGAS',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                const SizedBox(height: 16),
                TextFormField(
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
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Register()),
                    );
                  },
                  child: const Text(
                    'Register / Create Account',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 24,
                    color:Color.fromARGB(255, 60, 5, 100)),
                  ),
                ),
                loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              loading = true;
                            });
                            await FirebaseFirestore.instance
                                .collection('users')
                                .where('username', isEqualTo: username)
                                .where('password', isEqualTo: password)
                                .get()
                                .then(
                              (value) {
                                if (value.docs.length != 1) {
                                  setState(() {
                                    loading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "ล็อกอินไม่สำเร็จกรุณาล็อกอินใหม่อีกครั้ง",
                                      ),
                                    ),
                                  );
                                } else {
                                  prefs.setString(
                                      'role', value.docs[0]['role']);
                                  prefs.setString(
                                      'username', value.docs[0]['username']);
                                  prefs.setString(
                                      'address', value.docs[0]['address']);
                                  prefs.setString('phoneNumber',
                                      value.docs[0]['phoneNumber']);
                                  prefs.setString(
                                      'usernameId', value.docs[0].id);
                                  prefs.setString(
                                      'password', value.docs[0]['password']);
                                  setState(() {
                                    loading = false;
                                  });
                                  Phoenix.rebirth(context);
                                }
                              },
                            );
                          }
                        },
                        child: const Text('Login'),
                      ),
                      SizedBox(height: 30,),
                      const Text(
                          'เบอร์โทรศัพท์ 086-670-9232',
                          style: TextStyle(
                            fontSize: 25,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                          
                        ),
                        
                      
              ],
              
            ),
          ),
        ),
      ),
    );
  }
}
