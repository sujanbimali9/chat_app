import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/models/user.dart';
import 'package:chat/pages/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatelessWidget {
  final UserProfileController controller;
  final ChatUser user;
  const ChatUserCard({super.key, required this.controller, required this.user});

  @override
  Widget build(BuildContext context) {
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
        subtitle: Text(user.about),
        trailing: Text(
          user.lastActive,
          style: const TextStyle(color: Colors.black54),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: CachedNetworkImage(
            imageUrl: user.image,
            filterQuality: FilterQuality.high,
            fit: BoxFit.fill,
            height: 40,
            width: 40,
          ),
        ),
      ),
    );
  }
}
