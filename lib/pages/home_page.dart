import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/models/user.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/search_page.dart';
import 'package:chat/widgets/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  final UserProfileController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

late StreamSubscription<ConnectivityResult> subscription;

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {});
    log(subscription.toString());
    FirestoreMessaging.getFirebaseMessagingToken();
    if (Auth.auth.currentUser != null) {
      SystemChannels.lifecycle.setMessageHandler((message) {
        if (message.toString().contains('resume')) {
          FireStore.updateOnlineStatus(true);
        }
        if (message.toString().contains('pause')) {
          FireStore.updateOnlineStatus(false);
        }
        return Future.value(message);
      });
    }

    connection();
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.screenheight = MediaQuery.of(context).size.height.obs;
    widget.controller.screenwidth = MediaQuery.of(context).size.width.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        leading: IconButton(
            onPressed: () {
              widget.controller.isDarkModeEnabled.value =
                  !widget.controller.isDarkModeEnabled.value;
            },
            icon: Icon(widget.controller.isDarkModeEnabled.value
                ? Icons.dark_mode
                : Icons.dark_mode_outlined)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(
                      controller: widget.controller,
                    ),
                  ));
            },
            icon: const Icon(Icons.search_rounded),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                widget.controller.screenheight.value * 0.025,
              ),
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FireStore.getSelfUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data!.data() == null) {
                      return const Text('No data available');
                    } else {
                      ChatUser loggeduser =
                          ChatUser.fromJson(snapshot.data!.data()!);
                      final imageUrl = loggeduser.image.toString();

                      return InkWell(
                        borderRadius: BorderRadius.circular(
                          widget.controller.screenheight.value * 0.025,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfilePage(
                                controller: widget.controller,
                                user: loggeduser,
                              ),
                            ),
                          );
                        },
                        child: kIsWeb
                            ? Image.network(
                                imageUrl,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.fill,
                                height:
                                    widget.controller.screenheight.value * 0.05,
                                width:
                                    widget.controller.screenheight.value * 0.05,
                              )
                            : CachedNetworkImage(
                                imageUrl: imageUrl,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.cover,
                                height:
                                    widget.controller.screenheight.value * 0.05,
                                width:
                                    widget.controller.screenheight.value * 0.05,
                              ),
                      );
                    }
                  }),
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onPressed: () {},
          child: const Icon(
            Icons.message_rounded,
            size: 30,
          ),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: connection(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SizedBox.shrink();
                }
                if (snapshot.hasData && snapshot.data != null) {
                  if (!snapshot.data!) {
                    return const Text('waiting for network');
                  }
                }
                return const SizedBox();
              }),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FireStore.getUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasData) {
                      final data = snapshot.data!.docs;
                      List<ChatUser> list =
                          data.map((e) => ChatUser.fromJson(e.data())).toList();

                      return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return ChatUserCard(
                                controller: widget.controller,
                                user: list[index]);
                          });
                    }
                    return const Center(
                      child: Text('No data'),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> connection() async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi ||
      connectivityResult == ConnectivityResult.ethernet ||
      connectivityResult == ConnectivityResult.vpn ||
      connectivityResult == ConnectivityResult.bluetooth ||
      connectivityResult == ConnectivityResult.other) {
    return true;
  }
  return false;
}
