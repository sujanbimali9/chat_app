import 'package:chat/controller/controller.dart';
import 'package:chat/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeFirebase();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileController controller = Get.put(UserProfileController());
    return Obx(() => MaterialApp(
          title: 'Chat',
          theme: controller.isDarkModeEnabled.value
              ? ThemeData.dark(
                  useMaterial3: true,
                ).copyWith(
                  appBarTheme: const AppBarTheme(
                    iconTheme: IconThemeData(color: Colors.white),
                    centerTitle: true,
                    elevation: 0,
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  textTheme: Typography.whiteCupertino,
                )
              : ThemeData.light(
                  useMaterial3: true,
                ).copyWith(
                  appBarTheme: const AppBarTheme(
                    iconTheme: IconThemeData(color: Colors.black),
                    centerTitle: true,
                    elevation: 0,
                    titleTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  textTheme: Typography.blackCupertino,
                ),
          home: SplashScreen(controller: controller),
        ));
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
