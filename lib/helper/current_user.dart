import 'package:chat/api/apis.dart';

class CurrentUser {
  static final String id = APIs.user.uid;
  static final String name = APIs.user.displayName!;
  static final String email = APIs.user.email!;
  static final String image = APIs.user.photoURL!;
}
