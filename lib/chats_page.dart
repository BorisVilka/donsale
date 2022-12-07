

import 'dart:math';

import 'package:Donsale/chat_page.dart';
import 'package:Donsale/objects/chat.dart';
import 'package:Donsale/objects/chat_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Войдите или зарегистрируйтесь, чтобы добавлять объявления",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10,),
          ElevatedButton(onPressed: () async {
            launchTelegram();
          }, child: Container(
            width: 200,
            child:  Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send),
                SizedBox(width: 20,),
                Text("Поддержка")
              ],
            ),
          )
          ),
        ],
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
  var colors = [Colors.brown[200], Colors.blue, Colors.red, Colors.yellowAccent, Colors.amber, Colors.purple, Colors.lightGreenAccent, Colors.tealAccent, Colors.deepOrangeAccent];
  Widget buildItem(BuildContext context,int ind) {
    return Container(
      padding: EdgeInsets.all(2),
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatPage(ads: data[ind].ads,chat: data[ind],)));
        },
        child: Card(
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(top: 5,bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: CircleAvatar(
                    backgroundColor: colors[Random().nextInt(colors.length)],
                    radius: 25,
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
                    Text(data[ind].ads.author,style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(data[ind].ads.title),
                    SizedBox(height: 10,),
                    Container(
                      width: 250,
                      child: Text(data[ind].messages[data[ind].messages.length-1].txt,maxLines: 1,style: TextStyle(
                          overflow: TextOverflow.ellipsis,color: Colors.grey[800]
                      ),softWrap: true,),
                    )
                  ],
                )
              ],
            ),
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
      list = (value.data() ?? ChatList(list: []));
      //print(list.list.length+" len");
      setState(() {
        var tmp = <Chat>[];
        for(Chat i in list.list) {
          print(i.email2+" "+i.email1+" "+user!.photoURL!);
          print((i.email1 == user!.photoURL! ||
             i.email2 == user!.photoURL!));
          if(i.email1 == user!.photoURL! ||
              i.email2 == user!.photoURL!) tmp.add(i);
        }
        /*data = list.list.takeWhile((value) => value.email1 == user!.photoURL! ||
                      value.email2 == user!.photoURL!);*/
        data = tmp;
        print(data.length);
        //data = data.takeWhile((value) => contains(value.photoUrl) && (user!=null && value.email!=(user!.email ?? "") || user==null)).toList();
      });
    });
  }
  void launchTelegram() async{
    String url =
        "https://t.me/helpdonsale";
    print("launchingUrl: $url");
    if (await canLaunch(url)) {
      await launch(url);
    }

  }
}