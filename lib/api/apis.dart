import 'dart:io';
import 'package:chat/models/messages.dart';
import 'package:chat/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

//get current login method user detail
  static User get user => auth.currentUser!;

//check if user already exits or not
  static Future<bool> checkUser() async {
    final data = await firestore.collection('users').doc(user.uid).get();
    return data.exists;
  }

// add new user
  static Future<void> addUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        id: user.uid,
        name: user.displayName as String,
        email: user.email as String,
        image: user.photoURL as String,
        lastActive: DateTime.now().toUtc().toString(),
        about: 'chat',
        createdAt: time,
        isOnline: true,
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

//loggedin user details
  static late ChatUser me;

//funnction to get loggedin user details
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data() as Map<String, dynamic>);
      } else {
        await addUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<String> getImage() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        return ChatUser.fromJson(user.data() as Map<String, dynamic>).image;
      } else {
        await addUser().then((value) => getSelfInfo());
      }
    });
    return 'sujan';
  }

//stream to get the details of all users except currently loggedin
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return firestore
        .collection('users')
        .where(
          'id',
          isNotEqualTo: user.uid,
        )
        .snapshots();
  }

//update the user name and about
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

//update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me.image = await ref.getDownloadURL();

    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

//create conversion id for user
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

//stream to get messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      ChatUser user) {
    return firestore
        .collection('chat/${getConversationId(user.id)}/messages/')
        .snapshots();
  }

//function to sent message to user or push data to the firebase firestore database
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Chats message = Chats(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: Type.text.name,
        sent: time,
        fromId: user.uid,
        time: time);
    final ref = firestore
        .collection('chat/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateRead(Chats chat) async {
    firestore
        .collection('chat/${getConversationId(chat.fromId)}/messages/')
        .doc(chat.time)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }
}
