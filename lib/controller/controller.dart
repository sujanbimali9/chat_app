import 'package:get/get.dart';

class UserProfileController extends GetxController {
  var screenheight = 0.0.obs;
  var screenwidth = 0.0.obs;
  var searchData = ''.obs;

  void updateSearchData(String value) {
    searchData.value = value;
  }
}
