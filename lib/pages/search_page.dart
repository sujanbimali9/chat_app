import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/controller/controller.dart';
import 'package:chat/helper/current_datetime.dart';
import 'package:chat/models/user.dart';
import 'package:chat/pages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
    required this.controller,
  });
  final UserProfileController controller;

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    return PopScope(
      onPopInvoked: (didPop) => controller.updateSearchData(''),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              controller.updateSearchData(value);
            },
          ),
          actions: [
            Obx(
              () {
                if (controller.searchData != ''.obs) {
                  return IconButton(
                    onPressed: () {
                      controller.updateSearchData('');
                      searchController.clear();
                    },
                    icon: const Icon(Icons.close_rounded),
                  );
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
        body: Obx(
          () {
            if (controller.searchData == ''.obs) {
              return const SizedBox();
            } else {
              return StreamBuilder(
                stream: FireStore.getUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No user to search'),
                    );
                  }
                  final data = snapshot.data!.docs;
                  List<ChatUser> user =
                      data.map((e) => ChatUser.fromJson(e.data())).toList();
                  List<ExtractedResult<String>> searchResult = extractTop(
                      query: controller.searchData.value,
                      choices: user.map((e) => e.name).toList(),
                      limit: data.length,
                      cutoff: 50);
                  return ListView.builder(
                    itemCount: searchResult.length,
                    itemBuilder: (context, index) {
                      if (user
                          .map((e) => e.name)
                          .toList()
                          .contains(searchResult[index].choice)) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  controller: controller,
                                  user: user[index],
                                ),
                              ),
                            );
                          },
                          title: Text(
                            user[index].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(user[index].about),
                          trailing: Text(
                            CurrentDateTime.getTime(
                              context: context,
                              time: user[index].lastActive,
                            ),
                            style: const TextStyle(color: Colors.black54),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CachedNetworkImage(
                              imageUrl: user[index].image,
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.fill,
                              height: 40,
                              width: 40,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
