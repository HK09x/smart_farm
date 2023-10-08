import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_farm/main.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback callToSignIn;
  const SignUpPage({
    Key? key,
    required this.callToSignIn,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _imgController = TextEditingController();
  bool _isPhoneNumberValid = true;
  bool _isPasswordMatch = true;
  String? _emailErrorText;
  bool _isSignUpSuccess = false;

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _password2Controller.text.isEmpty ||
        _fullNameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง'),
        ),
      );
    } else if (_phoneNumberController.text.length != 10) {
      setState(() {
        _isPhoneNumberValid = false;
      });
    } else if (_passwordController.text == _password2Controller.text) {
      setState(() {
        _isPasswordMatch = true;
        _emailErrorText = null;
      });

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final User user = userCredential.user!;
        final String uid = user.uid;
        final String fullName = _fullNameController.text;
        final String phoneNumber = _phoneNumberController.text;
        final String email = _emailController.text;
        final String img = _imgController.text;
        final String info = _infoController.text;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'ID_users': uid,
          'Full_Name': fullName,
          'Phone_Number': phoneNumber,
          'Email': email,
          'img': img,
          'info': info,
        });
        final String house0 = 'house0'; // แก้ตามชื่อโรงเรือนที่ต้องการ
        await FirebaseFirestore.instance
            .collection('sensor_data')
            .doc(uid)
            .collection(house0)
            .doc('plot')
            .set({
          'info': '',
        });
        final String house1 = 'house1'; // แก้ตามชื่อโรงเรือนที่ต้องการ
        await FirebaseFirestore.instance
            .collection('sensor_data')
            .doc(uid)
            .collection(house1)
            .doc('plot')
            .set({
          'info': '',
        });
        final String house2 = 'house2'; // แก้ตามชื่อโรงเรือนที่ต้องการ
        await FirebaseFirestore.instance
            .collection('sensor_data')
            .doc(uid)
            .collection(house2)
            .doc('plot')
            .set({
          'info': '',
        });
        final String house3 = 'house3'; // แก้ตามชื่อโรงเรือนที่ต้องการ
        await FirebaseFirestore.instance
            .collection('sensor_data')
            .doc(uid)
            .collection(house3)
            .doc('plot')
            .set({
          'info': '',
        });
        final String house4 = 'house4'; // แก้ตามชื่อโรงเรือนที่ต้องการ
        await FirebaseFirestore.instance
            .collection('sensor_data')
            .doc(uid)
            .collection(house4)
            .doc('plot')
            .set({
          'info': '',
        });

        widget.callToSignIn();
        _isSignUpSuccess = true;
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          setState(() {
            _emailErrorText = 'อีเมลนี้ถูกใช้งานแล้ว';
          });
        } else {
          print('เกิดข้อผิดพลาดในการสมัครสมาชิก: ${error.message}');
        }
      }
    } else {
      setState(() {
        _isPasswordMatch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // กำหนดให้ภาพไม่ขยับเมื่อแสดงคีย์บอร์ด
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.all(0),
            child: Form(
              child: SingleChildScrollView(
                physics:
                    const NeverScrollableScrollPhysics(), // ไม่ให้ Scroll ด้านล่าง
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Stack(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: const Image(
                              image: AssetImage('images/พื้นหลัง1.jpg'),
                              fit: BoxFit
                                  .fill, // ใช้ BoxFit.contain เพื่อให้รูปแสดงพอดีกับ Container
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                height: 650,
                                width: 360,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            padding: const EdgeInsets.all(50),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 50,
                                ),
                                Center(
                                    child: Container(
                                  height: 130,
                                  width: 130,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: const DecorationImage(
                                          image: AssetImage('images/KU.png'),
                                          fit: BoxFit.cover)),
                                )),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  controller: _fullNameController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.account_circle_outlined,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    labelText: 'Username',
                                    labelStyle: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    labelText: 'Email',
                                    labelStyle: const TextStyle(
                                      fontSize: 15,
                                    ),
                                    errorText: _emailErrorText,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ), //
                                TextField(
                                  controller: _phoneNumberController,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.length == 10) {
                                        _isPhoneNumberValid = true;
                                      } else {
                                        _isPhoneNumberValid = false;
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.phone,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    labelText: 'เบอร์โทร',
                                    labelStyle: const TextStyle(
                                      fontSize: 15,
                                    ),
                                    errorText: _isPhoneNumberValid
                                        ? null
                                        : 'กรุณากรอกเบอร์โทรศัพท์ให้ครบ 10 หลัก',
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    labelText: 'Password',
                                    labelStyle: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  obscureText: true,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextField(
                                  controller: _password2Controller,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    labelText: 'Confirm Password',
                                    errorText: _isPasswordMatch
                                        ? null
                                        : 'รหัสผ่านไม่ตรงกัน',
                                    labelStyle: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  obscureText: true,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  height: 40,
                                  width: 150,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 21, 99, 51),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                    onPressed: () async {
                                      await _handleSignUp();
                                      if (_isSignUpSuccess) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage(), // หรือชื่อหน้าเข้าสู่ระบบ
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('SING UP'),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'กลับ',
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
