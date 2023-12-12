import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/pages/auth/loginscreen.dart';
import 'package:chat/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animated = false;
  @override
  void initState() {
    super.initState();
    final UserProfileController controller = Get.put(UserProfileController());
    Future.delayed(const Duration(milliseconds: 5), () {
      setState(() {
        _animated = true;
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (APIs.auth.currentUser != null) {
        APIs.firestore;
        APIs.getSelfInfo();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              controller: controller,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              controller: controller,
            ),
          ),
        );
      }
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedScale(
          scale: _animated ? 1.4 : 0,
          duration: const Duration(seconds: 1),
          child: Image.asset(
            'assets/icon/chat.png',
            scale: 5,
          ),
        ),
      ),
    );
  }
}
