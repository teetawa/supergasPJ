import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TextEditingController messageController;

  Map<String, dynamic> adminData = {};
  String userId = '';

  onSend() async {
    String text = messageController.text;
    if (text.isNotEmpty) {
      // send chat
      var chatData = ChatData(userId, adminData['username'], text);

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
    setupAdminProfile();
    setupMyProfile();
  }

  setupMyProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('username') ?? "";
  }

  setupAdminProfile() async {
    QuerySnapshot raw = await FirebaseFirestore.instance.collection('users').get();
    List<dynamic> data = raw.docs.map((e) => e.data()).toList();
    adminData = data.firstWhere((e) => e['role'] == 'admin');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ติดต่อแอดมิน")),
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
                      return (e.to == userId && e.from == adminData['username']) ||
                          (e.from == userId && e.to == adminData['username']);
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
    if (data.from == userId) {
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

class ChatData {
  final String from;
  final String to;
  final String text;
  int? timestamp;

  ChatData(this.from, this.to, this.text, {this.timestamp});

  factory ChatData.fromJson(Map<String, dynamic> json) =>
      ChatData(json['from'], json['to'], json['text'], timestamp: json['timestamp']);

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'text': text,
        'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
      };
}
