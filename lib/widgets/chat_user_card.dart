import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/helper/current_datetime.dart';
import 'package:chat/models/user.dart';
import 'package:chat/pages/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatelessWidget {
  final UserProfileController controller;
  final ChatUser user;
  const ChatUserCard({super.key, required this.controller, required this.user});

  @override
  Widget build(BuildContext context) {
    String lastmessage = user.about;
    // bool isRead = true;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChatScreen(
                        controller: controller,
                        user: user,
                      )));
        },
        title: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: StreamBuilder(
          stream: FireStore.getLastMessage(user.id),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            if (data != null && data.isNotEmpty) {
              lastmessage = data[0].data()['msg'];
            }
            return Text(lastmessage);
          },
        ),
        trailing: Text(
          CurrentDateTime.getCurrentTime(
            context: context,
            time: user.lastActive,
          ),
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CachedNetworkImage(
                imageUrl: user.image,
                filterQuality: FilterQuality.high,
                fit: BoxFit.fill,
                height: 40,
                width: 40,
              ),
            ),
            if (user.isOnline)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.black),
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
