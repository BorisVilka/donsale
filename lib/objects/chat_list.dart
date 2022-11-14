
import 'package:Donsale/objects/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatList {

  List<Chat> list;

  ChatList({required this.list});

  factory ChatList.fromFirestore(
      DocumentSnapshot<Map<String,dynamic>> snapshot,
      SnapshotOptions? options
      ) {
    var data = snapshot.data();
    return ChatList(list: List<Chat>.from(((data!['list'] ?? []) as List<dynamic>).map((e) => Chat.fromFirestore(e)).toList()));
  }
  Map<String,dynamic> toFirestore() {
    return {
      'list': List<dynamic>.from(list.map((e) => e.toFirestore())),
    };
  }
}