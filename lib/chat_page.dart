
import 'package:Donsale/objects/ads.dart';
import 'package:Donsale/objects/ads_list.dart';
import 'package:Donsale/objects/chat.dart';
import 'package:Donsale/objects/chat_list.dart';
import 'package:Donsale/objects/message.dart';
import 'package:Donsale/review_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ChatPage extends StatefulWidget {

  Chat? chat;
  Ads ads;

  ChatPage({required this.ads, this.chat});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChatState();
  }

}

class ChatState extends State<ChatPage> {

  late Chat chat;
  late bool init;
  bool sub = false;
  bool exist = true;
  List<Ads> data = [];
  User user = FirebaseAuth.instance.currentUser!;
  TextEditingController _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    if(widget.chat==null) {
      init = true;
      chat = Chat(
        id: widget.ads.id.toString(),
        email1: widget.ads.email,
        email2: user.photoURL!,
        messages: [], ads: widget.ads,
        review: -1
      );
    } else {
      init = false;
      chat = widget.chat!;
    }
    print(chat.ads.title);
    final ref = FirebaseFirestore.instance.collection("main")
        .doc("ads")
        .withConverter(fromFirestore: AdsList.fromFirestore, toFirestore:(AdsList list, _) => list.toFirestore());
    ref.get().then((value) {
      var list = (value.data() ?? AdsList(list: []));
      setState(() {
        data = list.list;
        exist = false;
        for(Ads i in data) {
          if(i.id==chat.ads.id) {
            exist = true;
            break;
          }
        }
      });
    });
    if(!init) {
      FirebaseFirestore.instance
          .collection("main")
          .doc("chats")
          .snapshots()
          .listen((event) {
            var tmp = ChatList.fromFirestore(event, null);
            for(Chat i in tmp.list) {
              if(i.email1==chat.email1 && i.email2==chat.email2 && i.ads.id==chat.ads.id) {
                setState(() {
                  chat = i;
                });
                break;
              }
            }
      });
    }
  }
  bool contains() {
    bool ans = false;
    for(Ads i in data) {
      if(i.id==chat.ads.id) {
        ans = true;
        break;
      }
    }
    return ans;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.brown[200],),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                  alignment: Alignment.topLeft,
                  color: Colors.white,
                  height: 65,
                  padding: EdgeInsets.only(left: 30,top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(chat.ads.title,textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                      SizedBox(height: 5,),
                      if(!exist) Text("Объявление снято с публикации")
                    ],
                  )
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.only(top: 60,left: 10,right: 10,bottom: 100),
                child: ListView.builder(itemBuilder: (context,ind) {
                      return chatItem(context,ind);
                  },
                  itemCount: chat.messages.length,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: exist ?  Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(child: TextField(
                      decoration: InputDecoration(
                          hintText: "Введите сообщение",
                          hintStyle: const TextStyle(color: Colors.black54),
                          border: InputBorder.none
                      ),
                      maxLines: 2,
                      minLines: 1,
                      controller: _text,
                    )
                    ),
                    IconButton(onPressed: () async {
                      if(_text.text.isEmpty) return;
                      if(init && !sub) {
                        sub = false;
                        FirebaseFirestore.instance
                            .collection("main")
                            .doc("chats")
                            .snapshots()
                            .listen((event) {
                          var tmp = ChatList.fromFirestore(event, null);
                          for(Chat i in tmp.list) {
                            if(i.email1==chat.email1 && i.email2==chat.email2 && i.ads.id==chat.ads.id) {
                              setState(() {
                                chat = i;
                              });
                              break;
                            }
                          }
                        });
                      }
                      final ref = FirebaseFirestore.instance.collection("main")
                          .doc("chats")
                          .withConverter(fromFirestore: ChatList.fromFirestore, toFirestore:(ChatList list, _) => list.toFirestore());
                      ref.get().then((value) {
                        var list = (value.data() ?? ChatList(list: []));
                        chat.messages.add(Message(txt: _text.text, phone: user.photoURL!, name: user.displayName!));
                        if(init) {
                          list.list.add(chat);
                        } else {
                          var ind = 0;
                          for(int j = 0;j<list.list.length;j++) {
                            final i = list.list[j];
                            if(i.email1==chat.email1 && i.email2==chat.email2 && i.ads.id==chat.ads.id) {
                              ind = j;
                              break;
                            }
                          }
                          list.list[ind] = chat;
                        }
                        FirebaseFirestore.instance
                            .collection("main")
                            .doc("chats")
                            .set(list.toFirestore());
                        _text.text = "";
                      });
                    }, icon: Icon(Icons.send))
                  ],
                ),
              )
                  : ((chat.review<0 && chat.ads.email!=user.photoURL) ? Container(
                margin: const EdgeInsets.only(bottom: 10,left: 20,right: 20),
                width: double.infinity,
                child: ElevatedButton(onPressed: () async {
                  chat.review = await  Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>ReviewPage(chat: chat)));
                  setState(() {});
                  FirebaseFirestore.instance.collection("main")
                      .doc("chats")
                      .withConverter(fromFirestore: ChatList.fromFirestore, toFirestore:(ChatList list, _) => list.toFirestore()).get().then((value) {
                        var list = value.data() ?? ChatList(list: []);
                        for(Chat i in list.list) {
                          if(i.id == chat.id && i.email2==chat.email2 && i.email1==chat.email1) {
                            i.review = chat.review;
                            break;
                          }
                        }
                        FirebaseFirestore.instance.collection("main").doc("chats").set(list.toFirestore());
                  });

                }, child: const Text("Оставить отзыв")),
              ) : const Padding(padding: EdgeInsets.only(bottom: 10),child: Text("Спасибо, что оставили отзыв",style: TextStyle(fontSize: 20),),)),
            )
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget chatItem(BuildContext context, int ind) {
    return Container(
      width: double.infinity,
      alignment: chat.messages[ind].phone==user.photoURL! ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Card(
        color: chat.messages[ind].phone==user.photoURL ? Colors.blue[100] : Colors.white,
        child: Container(
          padding: EdgeInsets.only(left: 15,top:10,bottom: 10,right: 10),
          child: Text(chat.messages[ind].txt),
        ),
      ),
    );
  }
}