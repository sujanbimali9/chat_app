import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/helper/current_datetime.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/models/user.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final UserProfileController controller;
  final ChatUser user;
  const ChatScreen({super.key, required this.controller, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Obx(
              () => InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        widget.controller.screenheight.value * 0.03,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.user.image,
                        height: widget.controller.screenheight.value * 0.06,
                        width: widget.controller.screenheight.value * 0.06,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: widget.controller.screenwidth.value * 0.04,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(widget.user.name),
                        Text(
                          widget.user.isOnline
                              ? 'Online'
                              : CurrentDateTime.getDateTime(
                                  context: context,
                                  time: widget.user.lastActive,
                                ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          body: Obx(
            () => Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FireStore.getMessage(widget.user.id),
                    builder: (context, snapshots) {
                      switch (snapshots.connectionState) {
                        case ConnectionState.waiting:
                          return const Center(
                              child: CircularProgressIndicator());
                        case ConnectionState.none:
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshots.data?.docs;

                          List<Chats> list = data
                                  ?.map((e) => Chats.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  chat: list[index],
                                  controller: widget.controller,
                                );
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
                  controller: widget.controller,
                  user: widget.user,
                ),
                if (widget.controller.showEmoji.value)
                  SizedBox(
                    height: widget.controller.screenheight * 0.4,
                    child: EmojiPicker(
                      onBackspacePressed: () {
                        widget.controller.textEditingController
                          ..text = widget
                              .controller.textEditingController.text.characters
                              .toString()
                          ..selection = TextSelection.fromPosition(
                            TextPosition(
                                offset: widget.controller.textEditingController
                                    .text.length),
                          );
                      },
                      textEditingController:
                          widget.controller.textEditingController,
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          )),
    );
  }
}

class MessageBar extends StatelessWidget {
  final ChatUser user;
  final UserProfileController controller;

  const MessageBar({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: controller.screenheight.value * 0.01,
          top: controller.screenheight.value * 0.01,
        ),
        child: Column(
          children: [
            if (controller.isUploading.value)
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: controller.screenwidth.value * 0.05),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(133, 177, 176, 176),
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          controller.showEmoji.value =
                              !controller.showEmoji.value;
                        },
                        icon: const Icon(Icons.emoji_emotions_rounded),
                      ),
                      SizedBox(
                        width: controller.screenwidth.value * 0.4,
                        child: TextField(
                          controller: controller.textEditingController,
                          onTap: () {
                            if (controller.showEmoji.value) {
                              controller.showEmoji.value =
                                  !controller.showEmoji.value;
                            }
                          },
                          onSubmitted: (value) {
                            if (controller
                                .textEditingController.text.isNotEmpty) {
                              FireStore.sendMessage(
                                  toid: user.id,
                                  msg: controller.textEditingController.text,
                                  type: Type.text);
                              controller.textEditingController.clear();
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type something ..',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final List<XFile?> photo =
                              await picker.pickMultiImage(
                            imageQuality: 100,
                          );
                          if (photo.isNotEmpty) {
                            photo.map(
                              (e) async {
                                controller.isUploading.value = true;
                                await FireStore.sendImage(
                                    user.id, File(e!.path));
                                controller.isUploading.value = false;
                              },
                            );
                          }
                        },
                        icon: const Icon(Icons.image),
                      ),
                      IconButton(
                        onPressed: () async {
                          final XFile? photo = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 100,
                          );
                          if (photo != null) {
                            FireStore.sendImage(user.id, File(photo.path));
                          }
                        },
                        icon: const Icon(Icons.camera_alt_rounded),
                      )
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (controller.textEditingController.text.isNotEmpty) {
                      FireStore.sendMessage(
                        toid: user.id,
                        msg: controller.textEditingController.text,
                        type: Type.text,
                      );
                      controller.textEditingController.clear();
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
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
    if (!chat.read) FireStore.updateRead(userid: chat.fromId, time: chat.time);
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
              child: chatContent(chat)),
        ),
      ],
    );
  }
}

class GreenMessage extends StatelessWidget {
  final Chats chat;
  final UserProfileController controller;
  const GreenMessage({
    super.key,
    required this.chat,
    required this.controller,
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
                child: chatContent(chat),
              ),
              if (chat.time.isNotEmpty && chat.read)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.done_all_rounded,
                    color: Colors.blue,
                  ),
                )
              else if (chat.time.isNotEmpty && controller.isUploading.value)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.done_all_outlined,
                    color: Color.fromARGB(179, 181, 181, 181),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class MessageCard extends StatelessWidget {
  final UserProfileController controller;
  final Chats chat;
  const MessageCard({
    super.key,
    required this.chat,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    bool isMe = Auth.user.uid == chat.fromId;

    return InkWell(
      // onLongPress: () {},
      child: isMe
          ? GreenMessage(
              chat: chat,
              controller: controller,
            )
          : BlueMessage(chat: chat),
    );
  }
}

Widget chatContent(Chats chat) {
  switch (chat.type) {
    case 'text':
      return Text(
        chat.msg,
      );
    case 'image':
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: chat.msg,
        ),
      );

    default:
      return Text(
        chat.msg,
      );
  }
}
