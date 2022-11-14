

import 'package:Donsale/chat_page.dart';
import 'package:Donsale/objects/chat.dart';
import 'package:Donsale/objects/chat_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ChatsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChatsState();
  }

}
class ChatsState extends State<ChatsPage> {

  User? user;
  List<Chat> data = [];
  bool first = true;

  @override
  void initState() {
    FirebaseAuth
        .instance
        .authStateChanges()
        .listen((User? user) {
      if(user!=null) {
        setState(() {
          this.user = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     appBar: AppBar(backgroundColor: Colors.brown[200],title: Text('Сообщения'),),
     body:
    ((user==null || (user?.isAnonymous ?? false)) ?
      buildEmpty() : buildSigned()
    ),
     backgroundColor: Colors.grey[100],
   );
  }
  Widget buildEmpty() {
    return const Center(
      child: Padding(padding: EdgeInsets.all(20),
        child: Text("Войдите или зарегистрируйтесь, чтобы добавлять объявления",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildSigned() {
    if(first) {
      getData();
      first = false;
    }
    print("signed");
    return Container(
      child: ListView.builder(
          itemBuilder: (context, ind) {
            return buildItem(context, ind);
          },
        itemCount: data.length,
      ),
    );
  }
  Widget buildItem(BuildContext context,int ind) {
    return Container(
      padding: EdgeInsets.all(2),
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatPage(ads: data[ind].ads,chat: data[ind],)));
        },
        child: Card(
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: CircleAvatar(
                  backgroundColor: Colors.brown[200],
                  radius: 20,
                  child: Center(
                    child: Text(
                      ((data[ind].ads.author)
                          .toUpperCase().isEmpty ? "П" : (data[ind].ads.author).toUpperCase())[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data[ind].ads.title,style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),
                  Container(
                    width: 250,
                    child: Text(data[ind].messages[data[ind].messages.length-1].txt,maxLines: 1,style: TextStyle(
                        overflow: TextOverflow.ellipsis
                    ),softWrap: true,),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  var list;
  void getData() async {
    final ref = FirebaseFirestore.instance.collection("main")
        .doc("chats")
        .withConverter(fromFirestore: ChatList.fromFirestore, toFirestore:(ChatList list, _) => list.toFirestore());
    print("get");
    ref.get().then((value) {
      list = (value.data() ?? ChatList(list: [])) as ChatList;
      //print(list.list.length+" len");
      setState(() {
        data = list.list;
        data = data.takeWhile((value) => value.email1==user!.phoneNumber! || value.email2==user!.phoneNumber!).toList();
        //data = data.takeWhile((value) => contains(value.photoUrl) && (user!=null && value.email!=(user!.email ?? "") || user==null)).toList();
      });
    });
  }
}