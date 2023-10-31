import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_farm/home_page.dart';
import 'package:smart_farm/login/sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
            .copyWith(background: const Color(0xFF2F4F4F)),
      ),
      home: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
          } else {
            final User? user = snapshot.data;
            if (user != null) {
              return HomePage(user);
            } else {
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // กำหนดให้ภาพไม่ขยับเมื่อแสดงคีย์บอร์ด
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: SingleChildScrollView(
            physics:
                const NeverScrollableScrollPhysics(), // ไม่ให้ Scroll ด้านล่าง
            child: Column(
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
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 100,
                              ),
                              Center(
                                  child: Container(
                                height: 190,
                                width: 190,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: const DecorationImage(
                                        image: AssetImage('images/KU.png'),
                                        fit: BoxFit.cover)),
                              )),
                              const SizedBox(
                                height: 60,
                              ),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(
                                    Icons.account_circle_outlined,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30)),
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
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30)),
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
                              SizedBox(
                                height: 40,
                                width: 150,

                                // width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 21, 99, 51),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                  onPressed: () async {
                                    String email = _emailController.text.trim();
                                    String password =
                                        _passwordController.text.trim();
                                    try {
                                      UserCredential userCredential =
                                          await _auth
                                              .signInWithEmailAndPassword(
                                        email: email,
                                        password: password,
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HomePage(userCredential.user!),
                                        ),
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'user-not-found') {
                                        setState(() {
                                          _errorMessage =
                                              'ไม่พบผู้ใช้งานด้วยอีเมลนี้';
                                        });
                                      } else if (e.code == 'wrong-password') {
                                        setState(() {
                                          _errorMessage = 'รหัสผ่านไม่ถูกต้อง';
                                        });
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(_errorMessage),
                                          duration: const Duration(
                                              seconds:
                                                  3), // แสดงเป็นเวลา 3 วินาที
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpPage(
                                        callToSignIn: () {},
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "SING UP",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
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
