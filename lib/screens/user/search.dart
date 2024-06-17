import 'package:flashbacks/models/user.dart';
import 'package:flashbacks/providers/api.dart';
import 'package:flashbacks/utils/widget.dart';
import 'package:flashbacks/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<Iterable<BasicUser>> futureSearchedUsers = Future.value([]);

  void handleSearchChange(String value) {
    setState(() {
      if (value == "") futureSearchedUsers = Future.value([]);
      else ApiModel.apiFromContext(context, (api) => futureSearchedUsers = api.user.search(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => context.go("/home"))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const Gap(10),
            TextField(
              onChanged: handleSearchChange,
              style: const TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                fillColor: Colors.black12,
                hintText: "Search for friends...",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Gap(25),
            getFutureBuilder<Iterable<BasicUser>>(futureSearchedUsers, (users) =>
              UserCollectionColumn(
                  collection: users.toList(),
                  onItemTap: (user) => context.go("/user/${user.id}", extra: "/user/search")
              )
            )
          ],
        ),
      ),
    );
  }
}