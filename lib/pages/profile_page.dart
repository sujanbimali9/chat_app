import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/pages/auth/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.controller});
  final UserProfileController controller;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    void showBottomSheet(
        BuildContext context, UserProfileController controller) {
      final ImagePicker picker = ImagePicker();
      showModalBottomSheet(
        context: context,
        builder: (context) => ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: controller.screenheight.value * 0.02),
              child: const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            SizedBox(
              height: controller.screenheight.value * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    final XFile? photo =
                        await picker.pickImage(source: ImageSource.camera);
                    if (photo != null) {
                      APIs.updateProfilePicture(File(photo.path));
                    }
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: controller.screenheight.value * 0.02,
                        horizontal: controller.screenwidth.value * 0.05),
                    child: Image.asset(
                      'assets/icon/camera.png',
                      width: controller.screenwidth.value * 0.15,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      APIs.updateProfilePicture(File(image.path));
                    }
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: controller.screenheight.value * 0.02,
                      horizontal: controller.screenwidth.value * 0.05,
                    ),
                    child: Image.asset(
                      'assets/icon/gallery.png',
                      width: controller.screenwidth.value * 0.15,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings_rounded),
            ),
          ],
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            reverse: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Obx(
                    () => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              controller.screenheight.value * 0.1),
                          child: CachedNetworkImage(
                            imageUrl: APIs.me.image,
                            height: controller.screenheight.value * 0.2,
                            width: controller.screenheight.value * 0.2,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -1,
                          child: MaterialButton(
                            color: Colors.white,
                            elevation: 0,
                            onPressed: () {
                              showBottomSheet(context, controller);
                            },
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  APIs.me.email,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                SizedBox(
                  height: controller.screenheight.value * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: controller.screenheight.value * 0.05),
                  child: TextFormField(
                    onSaved: (newValue) => APIs.me.name = newValue ?? '',
                    validator: (value) {
                      return value != null && value.isNotEmpty
                          ? null
                          : 'Required Field';
                    },
                    initialValue: APIs.me.name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      isDense: true,
                      hintText: 'profile name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                SizedBox(
                  height: controller.screenheight.value * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: controller.screenheight.value * 0.05),
                  child: TextFormField(
                    initialValue: APIs.me.about,
                    onSaved: (newValue) => APIs.me.about = newValue ?? '',
                    validator: (value) {
                      return value != null && value.isNotEmpty
                          ? null
                          : 'Required Field';
                    },
                    decoration: const InputDecoration(
                      labelText: 'About',
                      isDense: true,
                      hintText: 'about',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outline_rounded),
                    ),
                  ),
                ),
                SizedBox(
                  height: controller.screenheight.value * 0.02,
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      APIs.updateUserInfo();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Update'),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FilledButton.icon(
          style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent.shade200.withOpacity(0.9)),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            await GoogleSignIn().signOut().then((value) {
              // Navigator.pop(context);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(controller: controller),
                ),
                (route) => false,
              );
            });
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ),
    );
  }
}
