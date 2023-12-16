import 'package:chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  var screenheight = 0.0.obs;
  var screenwidth = 0.0.obs;
  var searchData = ''.obs;
  TextEditingController textEditingController = TextEditingController();
  var showEmoji = false.obs;
  var canPop = false.obs;
  var isUploading = false.obs;
  void updateSearchData(String value) {
    searchData.value = value;
  }

  // Rx<ChatUser> user = ChatUser(
  //         image:
  //             'https://images.unsplash.com/photo-1575936123452-b67c3203c357?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D',
  //         name: 'name',
  //         about: 'about',
  //         createdAt: 'createdAt',
  //         lastActive: 'lastActive',
  //         isOnline: false,
  //         id: 'id',
  //         pushToken: 'pushToken',
  //         email: 'email')
  //     .obs;
}
