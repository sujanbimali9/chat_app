import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/helper/dialog.dart';
import 'package:chat/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  final UserProfileController controller;
  const LoginPage({super.key, required this.controller});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _googleLoginClick(UserProfileController controller) {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if (await FireStore.checkUser()) {
          Future.microtask(
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(
                  controller: controller,
                ),
              ),
            ),
          );
        } else {
          await FireStore.addUser().then(
            (value) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(
                  controller: controller,
                ),
              ),
            ),
          );
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await Auth.auth.signInWithCredential(credential);
    } catch (e) {
      Future.microtask(
        () => Dialogs.showSnackbar(context, 'No internet connection'),
      );

      return null;
    }
  }

  bool _visible = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(microseconds: 200), () {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.screenwidth = MediaQuery.of(context).size.width.obs;
    widget.controller.screenheight = MediaQuery.of(context).size.height.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: widget.controller.screenheight * 0.6,
            top: widget.controller.screenheight * 0.05,
            left: widget.controller.screenwidth * 0.25,
            right: widget.controller.screenwidth * 0.25,
            child: AnimatedScale(
              duration: const Duration(seconds: 1),
              scale: _visible ? 0.8 : 0,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(seconds: 1),
                child: Image.asset(
                  'assets/icon/chat.png',
                ),
              ),
            ),
          ),
          Positioned(
            bottom: widget.controller.screenheight * 0.05,
            left: widget.controller.screenwidth * 0.09,
            right: widget.controller.screenwidth * 0.09,
            top: widget.controller.screenheight * 0.35,
            child: Column(
              children: [
                LoginButton(
                  onPressed: () {
                    _googleLoginClick(widget.controller);
                  },
                  loginIconLocation: 'assets/icon/google.png',
                  title: 'Login with Google',
                  height: widget.controller.screenheight.value,
                ),
                LoginButton(
                  onPressed: () {},
                  loginIconLocation: 'assets/icon/facebook.png',
                  title: 'Login with Facebook',
                  height: widget.controller.screenheight.value,
                ),
                LoginButton(
                  onPressed: () {},
                  loginIconLocation: 'assets/icon/email.png',
                  title: 'Login with Email',
                  height: widget.controller.screenheight.value,
                ),
                LoginButton(
                  onPressed: () {},
                  loginIconLocation: 'assets/icon/phone-call.png',
                  title: 'Login with Phone',
                  height: widget.controller.screenheight.value,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.onPressed,
    required this.loginIconLocation,
    required this.title,
    required this.height,
  });

  final Null Function() onPressed;
  final String loginIconLocation;
  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Image.asset(
                loginIconLocation,
                height: height * 0.03,
                filterQuality: FilterQuality.high,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 17, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
