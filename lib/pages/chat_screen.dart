import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/helper/current_datetime.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  final UserProfileController controller;
  final ChatUser user;
  const ChatScreen({super.key, required this.controller, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => InkWell(
            onTap: () {},
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    controller.screenheight.value * 0.03,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: user.image,
                    height: controller.screenheight.value * 0.06,
                    width: controller.screenheight.value * 0.06,
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: controller.screenwidth.value * 0.04,
                ),
                Column(
                  children: [
                    Text(user.name),
                    Text(user.lastActive),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FireStore.getMessage(user.id),
              builder: (context, snapshots) {
                switch (snapshots.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshots.data?.docs;

                    List<Chats> list =
                        data?.map((e) => Chats.fromJson(e.data())).toList() ??
                            [];
                    if (list.isNotEmpty) {
                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return MessageCard(chat: list[index]);
                        },
                      );
                    } else {
                      return const Center(child: Text('Say Hi!!'));
                    }
                }
              },
            ),
          ),
          MessageBar(
            controller: controller,
            user: user,
          ),
        ],
      ),
    );
  }
}

class MessageBar extends StatelessWidget {
  final ChatUser user;
  const MessageBar({
    super.key,
    required this.user,
    required this.controller,
  });

  final UserProfileController controller;

  @override
  Widget build(BuildContext context) {
    TextEditingController textcontroller = TextEditingController();
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            margin: EdgeInsets.only(left: controller.screenwidth.value * 0.05),
            decoration: BoxDecoration(
                color: const Color.fromARGB(133, 177, 176, 176),
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.emoji_emotions_rounded),
                ),
                SizedBox(
                  width: controller.screenwidth.value * 0.45,
                  child: TextField(
                    controller: textcontroller,
                    onTap: () {
                      // APIs.updateRead(chat);
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type something ..',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.image),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_rounded),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (textcontroller.text.isNotEmpty) {
                FireStore.sendMessage(toid: user.id, msg: textcontroller.text);
                textcontroller.clear();
              }
            },
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}

class BlueMessage extends StatelessWidget {
  final Chats chat;
  const BlueMessage({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    // FireStore.updateRead(chat.toId);
    return Column(
      children: [
        if (int.parse(DateTime.now()
                .difference(
                    DateTime.fromMillisecondsSinceEpoch(int.parse(chat.time)))
                .toString()
                .split(':')[1]) <
            30)
          Center(
            child: Text(CurrentDateTime.formatedDateTime(
                context: context, time: chat.time)),
          ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 200, top: 10),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Text(
              chat.msg,
            ),
          ),
        ),
      ],
    );
  }
}

class GreenMessage extends StatelessWidget {
  final Chats chat;
  const GreenMessage({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (int.parse(DateTime.now()
                .difference(
                    DateTime.fromMillisecondsSinceEpoch(int.parse(chat.time)))
                .toString()
                .split(':')[1]) >
            30)
          Center(
            child: Text(CurrentDateTime.formatedDateTime(
                context: context, time: chat.time)),
          ),
        Align(
          alignment: Alignment.topRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 200, right: 10, top: 10),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  color:
                      const Color.fromARGB(255, 68, 255, 124).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Text(
                  chat.msg,
                ),
              ),
              if (chat.time.isNotEmpty && chat.read)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.done_all_rounded,
                    color: Colors.blue,
                  ),
                )
              else if (chat.time.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.done_all_outlined,
                    color: Color.fromARGB(179, 181, 181, 181),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}

class MessageCard extends StatelessWidget {
  final Chats chat;
  const MessageCard({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    bool isMe = Auth.user.uid == chat.fromId;

    return InkWell(
      onLongPress: () {},
      child: isMe ? GreenMessage(chat: chat) : BlueMessage(chat: chat),
    );
  }
}
