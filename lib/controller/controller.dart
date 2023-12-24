import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  var isDarkModeEnabled = false.obs;
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
}
