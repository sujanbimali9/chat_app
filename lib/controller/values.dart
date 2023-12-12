// import 'package:chat/controller/controller.dart';
// import 'package:chat/models/user.dart';
// import 'package:get/get.dart';

// class UserInfo {
//   final UserProfileController controller;
//   UserInfo({required this.controller});
//   String get id => controller.uid.value;
//   String get name => controller.name.value;
//   String get email => controller.email.value;
//   String get image => controller.image.value;
//   String get lastonline => controller.lastonline.value;
//   bool get isonline => controller.isonline.value;
//   String get about => controller.about.value;
// }

// UserInfo userInfo(UserProfileController controller, ChatUser user) {
//   controller.name = user.name.obs;
//   controller.email = user.email.obs;
//   controller.image = user.image.obs;
//   controller.uid = user.id.obs;
//   controller.lastonline = user.lastActive.obs;
//   controller.isonline = user.isOnline.obs;
//   controller.about = user.about.obs;
//   return UserInfo(controller: controller);
// }
