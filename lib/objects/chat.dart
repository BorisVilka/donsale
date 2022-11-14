

import 'package:Donsale/objects/ads.dart';
import 'package:Donsale/objects/message.dart';

class Chat {
  String id, email1, email2;
  List<Message> messages;
  Ads ads;

  Chat({
    required this.id, required this.email1, required this.email2,
    required this.messages,
    required this.ads
  });

  factory Chat.fromFirestore(
      Map<String,dynamic> data
      ) => Chat(id: data['id'],
      email1: data['email1'],
      email2: data['email2'],
      ads: Ads.fromFirestore(data['ads']),
      messages: List<Message>.from(((data['messages'] ?? []) as List<dynamic>).map((e) => Message.fromFirestore(e)).toList())
  );

  Map<String,dynamic> toFirestore() =>{
    'id':id,
    'email1':email1,
    'email2':email2,
    'messages': List<dynamic>.from(messages.map((e) => e.toFirestore()).toList()),
    'ads': ads.toFirestore()
  };
}