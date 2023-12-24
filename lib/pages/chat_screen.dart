import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/helper/current_datetime.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/models/user.dart';
import 'package:chat/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
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
    widget.controller.showEmoji.value = false;
    widget.controller.textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showUpdateMesssageDialog(
        {required Chats chat, required BuildContext scaffoldContext}) {
      showDialog(
          context: scaffoldContext,
          builder: (_) {
            final TextEditingController _textController =
                TextEditingController();
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.message),
                  Text('update meassage'),
                ],
              ),
              content: TextFormField(
                controller: _textController,
                initialValue: chat.msg,
                decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('cancel'),
                ),
                MaterialButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty)
                      FireStore.editMessage(
                        userid: chat.toId,
                        time: chat.time,
                        msg: _textController.text,
                      ).then(
                        (value) => Navigator.pop(context),
                      );
                  },
                  child: Text('update'),
                )
              ],
            );
          });
    }

    bottomSheet(
        {required Chats chat,
        required UserProfileController controller,
        required BuildContext scaffoldContext}) {
      FocusScope.of(context).unfocus;
      showBottomSheet(
        context: scaffoldContext,
        builder: (_) {
          bool isMe = chat.toId == Auth.user.uid;
          String sentTime = CurrentDateTime.fullDateTime(
            context: context,
            time: chat.sentTime,
          );
          String readTime = chat.readTime.isEmpty
              ? 'not seen yet'
              : CurrentDateTime.fullDateTime(
                  context: context,
                  time: chat.readTime,
                );

          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: controller.screenheight * 0.005,
                margin: EdgeInsets.symmetric(
                  horizontal: controller.screenwidth * 0.35,
                  vertical: controller.screenheight * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius:
                      BorderRadius.circular(controller.screenwidth * 0.1),
                ),
              ),
              chat.type == 'text'
                  ? OptionItems(
                      onTap: () async {
                        Navigator.pop(scaffoldContext);
                        await Clipboard.setData(ClipboardData(text: chat.msg))
                            .then(
                          (value) {
                            return ScaffoldMessenger.of(scaffoldContext)
                                .showSnackBar(
                              const SnackBar(
                                duration: Duration(microseconds: 1000000),
                                content: Text('copied to clipboard'),
                              ),
                            );
                          },
                        );
                      },
                      icons: const Icon(Icons.copy),
                      title: 'copy text',
                      controller: controller,
                    )
                  : OptionItems(
                      onTap: () async {
                        Navigator.pop(context);
                        if (connection() != ConnectionState.none)
                          try {
                            GallerySaver.saveImage(chat.msg).then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(microseconds: 1000000),
                                  content: Text('image saved to gallary'),
                                ),
                              );
                              return;
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(microseconds: 1000000),
                                content: Text(
                                    'saved to gallary failed with error : $e'),
                              ),
                            );
                          }
                      },
                      icons: const Icon(
                        Icons.download,
                      ),
                      title: 'save image',
                      controller: controller,
                    ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: controller.screenwidth * 0.06),
                child: const Divider(),
              ),
              if (chat.type == 'text' && !isMe)
                OptionItems(
                  onTap: () {
                    Navigator.pop(context);
                    showUpdateMesssageDialog(
                        chat: chat, scaffoldContext: scaffoldContext);
                  },
                  icons: const Icon(Icons.edit),
                  title: 'edit message',
                  controller: controller,
                ),
              if (!isMe)
                chat.type == 'text'
                    ? OptionItems(
                        onTap: () async {
                          await FireStore.deleteMessage(chat)
                              .then((value) => Navigator.pop(context));
                        },
                        icons: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        title: 'Delete message',
                        controller: controller,
                      )
                    : OptionItems(
                        onTap: () async {
                          await FireStore.deleteMessage(chat).then(
                            (value) => Navigator.pop(context),
                          );
                        },
                        icons: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        title: 'Delete image',
                        controller: controller,
                      ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: controller.screenwidth * 0.06),
                child: const Divider(),
              ),
              OptionItems(
                onTap: () {},
                icons: const Icon(
                  Icons.remove_red_eye_rounded,
                  color: Colors.blueAccent,
                ),
                title: 'sent time : $sentTime',
                controller: controller,
              ),
              OptionItems(
                onTap: () {},
                icons: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.blueAccent,
                ),
                title: chat.readTime.isEmpty
                    ? 'read time : not seen yet'
                    : 'read time : $readTime',
                controller: controller,
              ),
            ],
          );
        },
      );
    }

    greenMessage({
      required Chats chat,
      required BuildContext ScaffoldContext,
      required UserProfileController controller,
    }) {
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
                  context: ScaffoldContext, time: chat.time)),
            ),
          Align(
            alignment: Alignment.topRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onLongPress: () {
                    FocusScope.of(context).unfocus();
                    bottomSheet(
                      scaffoldContext: ScaffoldContext,
                      chat: chat,
                      controller: controller,
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.only(left: 200, right: 10, top: 10),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      color: const Color.fromARGB(255, 68, 255, 124)
                          .withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: chatContent(chat),
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
                  ),
              ],
            ),
          ),
        ],
      );
    }

    blueMessage({
      required Chats chat,
      required BuildContext scaffoldContext,
      required UserProfileController controller,
    }) {
      if (!chat.read) {
        FireStore.updateRead(
          userid: chat.fromId,
          time: chat.time,
        );
      }
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
                  context: scaffoldContext, time: chat.time)),
            ),
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onLongPress: () {
                FocusScope.of(scaffoldContext).unfocus();
                bottomSheet(
                  scaffoldContext: scaffoldContext,
                  chat: chat,
                  controller: controller,
                );
              },
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
          ),
        ],
      );
    }

    messageCard(
        {required Chats chat,
        required UserProfileController controller,
        required BuildContext scaffoldContext}) {
      bool isMe = Auth.user.uid == chat.fromId;

      return isMe
          ? greenMessage(
              ScaffoldContext: scaffoldContext,
              chat: chat,
              controller: controller,
            )
          : blueMessage(
              scaffoldContext: scaffoldContext,
              chat: chat,
              controller: controller,
            );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: () {},
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FireStore.getUserInfo(widget.user),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data!.data() == null) {
                      return const Text('No data available');
                    } else {
                      final user = snapshot.data!.data();

                      return Row(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: kIsWeb
                                    ? Image.network(
                                        user!['image'],
                                        filterQuality: FilterQuality.high,
                                        fit: BoxFit.fill,
                                        height: 40,
                                        width: 40,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: user!['image'],
                                        filterQuality: FilterQuality.high,
                                        fit: BoxFit.cover,
                                        height: 40,
                                        width: 40,
                                      ),
                              ),
                              if (user['isOnline'])
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
                          SizedBox(
                            width: widget.controller.screenwidth.value * 0.04,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['name']),
                              Text(
                                user['isOnline']
                                    ? 'Online'
                                    : CurrentDateTime.getDateTime(
                                        context: context,
                                        time: user['last_active'],
                                      ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      widget.controller.isDarkModeEnabled.value
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    }
                  }),
            ),
          ),
          body: Obx(
            () => Column(
              children: [
                if (connection() == ConnectionState.none)
                  const Text('waiting for network'),
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
                                return messageCard(
                                  scaffoldContext: context,
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
          child: Obx(
            () => Column(
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
                          color: controller.isDarkModeEnabled.value
                              ? Colors.black
                              : const Color.fromARGB(133, 177, 176, 176),
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
                                      msg:
                                          controller.textEditingController.text,
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
                                for (XFile? e in photo) {
                                  controller.isUploading.value = true;
                                  await FireStore.sendImage(
                                          user.id, File(e!.path))
                                      .then((value) {
                                    controller.isUploading.value = false;
                                  });
                                }
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
          )),
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
        child: kIsWeb
            ? Image.network(
                chat.msg,
              )
            : CachedNetworkImage(
                imageUrl: chat.msg,
              ),
      );

    default:
      return Text(
        chat.msg,
      );
  }
}

class OptionItems extends StatelessWidget {
  final String title;
  final Icon icons;
  final VoidCallback onTap;
  final UserProfileController controller;
  const OptionItems(
      {super.key,
      required this.onTap,
      required this.icons,
      required this.title,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: controller.screenwidth * 0.01,
          vertical: controller.screenheight * 0.01,
        ),
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: controller.screenwidth * 0.05),
          child: Row(
            children: [
              icons,
              SizedBox(
                width: controller.screenwidth * 0.03,
              ),
              Text(
                title,
                style: TextStyle(
                  color:
                      title == 'Delete message' ? Colors.red : Colors.black45,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
