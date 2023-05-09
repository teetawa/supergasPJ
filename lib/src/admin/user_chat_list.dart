import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../user/chat.dart';
import 'chat_user.dart';

class UserChatList extends StatefulWidget {
  const UserChatList({super.key});

  @override
  State<UserChatList> createState() => _UserChatListState();
}

class _UserChatListState extends State<UserChatList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ผู้ใช้ที่ขอทำการติดต่อ"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('chats').snapshots(),
          builder: (_, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<ChatData> lastChatList = [];
              List<ChatData> data = (snapshot.data.docs as List)
                  .map((e) => ChatData.fromJson(e.data()))
                  .toList()
                  .where((e) => e.to == 'admin')
                  .toList();
              data.sort((a, b) =>
                  DateTime.fromMillisecondsSinceEpoch(a.timestamp ?? DateTime.now().millisecondsSinceEpoch).compareTo(
                      DateTime.fromMillisecondsSinceEpoch(b.timestamp ?? DateTime.now().millisecondsSinceEpoch)));
              for (var chat in data) {
                int existIndex = lastChatList.indexWhere((e) => e.to == 'admin' && e.from == chat.from);
                if (existIndex == -1) {
                  lastChatList.add(chat);
                } else {
                  lastChatList[existIndex] = chat;
                }
              }

              return ListView.separated(
                itemBuilder: (context, index) => buildUser(context, lastChatList[index]),
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemCount: lastChatList.length,
              );
            } else {
              return Container();
            }
          }),
    );
  }

  Widget buildUser(BuildContext context, ChatData lastChat) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatUserPage(data: lastChat)));
        },
        title: Text(lastChat.text),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ผู้ใช้ ${lastChat.from}"),
            Text(
                "ได้ส่งข้อความถึงคุณเมื่อ ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(lastChat.timestamp ?? DateTime.now().millisecondsSinceEpoch))}"),
          ],
        ),
        trailing: Icon(Icons.chat),
      ),
    );
  }
}
