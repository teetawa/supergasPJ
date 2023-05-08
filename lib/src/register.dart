import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
  double latitude = 0.0;
  double longitude = 0.0;

  late TextEditingController locationController;

  @override
  void initState() {
    locationController = TextEditingController();
    super.initState();
    setupLocation();
  }

  setupLocation() async {
    Position position = await _determinePosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;

      locationController.text = "$latitude,$longitude";
    });
  }

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
        title: const Text('Register Page'),
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
                TextFormField(
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
                      icon: Icon(showConfirmPassword ? Icons.visibility : Icons.visibility_off),
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
                  controller: locationController,
                  enabled: false,
                  decoration: InputDecoration(
                    focusedBorder: focusedBorder,
                    enabledBorder: enabledBorder,
                    disabledBorder: enabledBorder,
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
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (password == confirmPassword) {
                              setState(() {
                                passwordNotMatch = false;
                                loading = true;
                              });
                              await FirebaseFirestore.instance.collection('users').add({
                                'username': username,
                                'password': password,
                                'address': address,
                                'phoneNumber': phoneNumber,
                                'role': 'user',
                                'creat_at': DateTime.now(),
                                'update_at': DateTime.now(),
                              });
                              setState(() {
                                loading = false;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("สมัครสมาชิกเรียบร้อยแล้ว"),
                              ));
                            } else {
                              setState(() {
                                passwordNotMatch = true;
                              });
                            }
                          }
                        },
                        child: const Text(
                          'สมัครสมาชิก',
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

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
