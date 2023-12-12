import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/helper/current_user.dart';
import 'package:chat/models/user.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/search_page.dart';
import 'package:chat/widgets/chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  final UserProfileController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // APIs.getUsers();
    // APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.screenheight = MediaQuery.of(context).size.height.obs;
    widget.controller.screenwidth = MediaQuery.of(context).size.width.obs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  widget.controller.screenheight.value * 0.025,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                        controller: widget.controller,
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: CurrentUser.image,
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.fill,
                  height: widget.controller.screenheight.value * 0.05,
                  width: widget.controller.screenheight.value * 0.05,
                ),
              ),
            ),
          ),
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
      body: StreamBuilder(
        stream: APIs.getUsers(),
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
                          controller: widget.controller, user: list[index]);
                    });
              }
              return const Center(
                child: Text('No data'),
              );
          }
        },
      ),
    );
  }
}
