import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supergas/src/user/chat.dart';

class ChatUserPage extends StatefulWidget {
  final ChatData data;
  const ChatUserPage({super.key, required this.data});

  @override
  State<ChatUserPage> createState() => _ChatUserPageState();
}

class _ChatUserPageState extends State<ChatUserPage> {
  ChatData get lastChat => widget.data;

  late TextEditingController messageController;

  onSend() async {
    String text = messageController.text;
    if (text.isNotEmpty) {
      // send chat
      var chatData = ChatData(lastChat.to, lastChat.from, text);

      // store to firebase
      await FirebaseFirestore.instance.collection('chats').add(chatData.toJson());
    }

    messageController.clear();
    // ignore: use_build_context_synchronously
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สนทนากับ ${lastChat.from}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('chats').orderBy('timestamp', descending: true).snapshots(),
                builder: (_, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    List<ChatData> data =
                        (snapshot.data.docs as List).map((e) => ChatData.fromJson(e.data())).toList().where((e) {
                      return (e.to == lastChat.to && e.from == lastChat.from) ||
                          (e.from == lastChat.to && e.to == lastChat.from);
                    }).toList();
                    data.sort((a, b) => DateTime.fromMillisecondsSinceEpoch(
                            a.timestamp ?? DateTime.now().millisecondsSinceEpoch)
                        .compareTo(
                            DateTime.fromMillisecondsSinceEpoch(b.timestamp ?? DateTime.now().millisecondsSinceEpoch)));
                    return ListView.separated(
                      cacheExtent: 10.0,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => SizedBox(height: 10),
                      itemCount: data.length,
                      itemBuilder: (context, index) => _buildChat(context, data[index]),
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextFormField(
              controller: messageController,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.send),
                labelText: 'ข้อความ',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              onEditingComplete: onSend,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChat(context, ChatData data) {
    if (data.from == lastChat.to) {
      return _buildUserChat(data);
    } else {
      return _buildAdminChat(data);
    }
  }

  Widget _buildUserChat(ChatData data) {
    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.green.shade100.withOpacity(0.5),
            ),
            constraints: BoxConstraints(maxWidth: 120),
            alignment: Alignment.centerRight,
            child: Text(data.text)),
      ),
    );
  }

  Widget _buildAdminChat(ChatData data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.black.withOpacity(0.3),
          ),
          constraints: BoxConstraints(maxWidth: 120),
          child: Text(data.text)),
    );
  }
}
