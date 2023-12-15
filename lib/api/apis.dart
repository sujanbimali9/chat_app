import 'dart:async';
import 'dart:io';
import 'package:chat/models/messages.dart';
import 'package:chat/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Auth {
  // instance of firebase auth
  static FirebaseAuth auth = FirebaseAuth.instance;

  // get current login method user detail
  static User get user => auth.currentUser!;
}

class FireStore {
  // instance of firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // check the user in the firestore
  static Future<bool> checkUser() async {
    final data = await firestore.collection('users').doc(Auth.user.uid).get();
    // returns true if user exists
    return data.exists;
  }

  // add user in firestore
  static Future<void> addUser() async {
    final date = DateTime.now().microsecondsSinceEpoch.toString();
    final user = Auth.user;
    final chatuser = ChatUser(
      image: user.photoURL.toString(),
      name: user.displayName.toString(),
      about: user.email.toString(),
      createdAt: date.toString(),
      lastActive: date.toString(),
      isOnline: true,
      id: user.uid,
      pushToken: '',
      email: user.email.toString(),
    );
    // push data to the database named "user" with userid and then userdata
    await firestore.collection('users').doc(user.uid).set(chatuser.toJson());
  }

  // currently user data of logged in user from firestore
  static late ChatUser me;

  // get userdata of currently loggedin user
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getSelfUser() {
    // get user data from firestore
    return firestore.collection('users').doc(Auth.user.uid).snapshots();
  }

  // function that return stream of data of user logged in
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: Auth.user.uid)
        .snapshots();
  }

  // update user name and about
  static Future updateUserInfo(String name, String about) async {
    await firestore.collection('users').doc(Auth.user.uid).update(
      {
        'name': name,
        'about': about,
      },
    );
  }

  // update profile picture of user (first add the profilePicture to the firestorage and then update the image location in database)
  static Future<void> updateProfilePicture(File file) async {
    final extension = file.path.split('.').last;
    final ref = FireStorage.storage
        .ref()
        .child('profile_pictures/${Auth.user.uid}.$extension');
    ref.putFile(
      file,
      SettableMetadata(contentType: 'image/$extension'),
    );
    await firestore.collection('users').doc(Auth.user.uid).update(
      {
        'image': await ref.getDownloadURL(),
      },
    );
  }

  //create conversation id for conversation
  static String getConversionId(String id) {
    print(Auth.user.uid.hashCode <= id.hashCode);

    return Auth.user.uid.hashCode <= id.hashCode
        ? '${Auth.user.uid}_$id'
        : '${id}_${Auth.user.uid}';
  }

  // function that return stream of messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessage(String userid) {
    return firestore
        .collection('chat/${getConversionId(userid)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(
      {required String msg, required String toid}) async {
    final String time = DateTime.now().microsecondsSinceEpoch.toString();
    final Chats message = Chats(
        msg: msg,
        toId: toid,
        read: false,
        type: Type.text.toString(),
        fromId: Auth.user.uid,
        time: time);
    await firestore
        .collection('chat/${getConversionId(
          toid,
        )}/messages/')
        .doc(time)
        .set(message.toJson());
  }

  static Future<void> updateRead(String userid) async {
    firestore
        .collection('chats/${getConversionId(userid)}/messages/')
        .doc()
        .update(
      {'read': true},
    );
  }
}

class FireStorage {
  // instance of firestorage
  static FirebaseStorage storage = FirebaseStorage.instance;
}
