import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/pages/auth/loginscreen.dart';
import 'package:chat/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  final UserProfileController controller;
  const SplashScreen({super.key, required this.controller});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animated = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Future.delayed(const Duration(milliseconds: 5), () {
      setState(() {
        _animated = true;
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (Auth.auth.currentUser != null) {
        FireStore.firestore;
        FireStore.getSelfUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              controller: widget.controller,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              controller: widget.controller,
            ),
          ),
        );
      }

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
