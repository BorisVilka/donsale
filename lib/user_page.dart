

import 'dart:math';

import 'package:Donsale/edit_user.dart';
import 'package:Donsale/objects/review.dart';
import 'package:Donsale/objects/review_list.dart';
import 'package:Donsale/reg_page.dart';
import 'package:Donsale/sign_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';


class UserPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return UserState();
  }
  
}

class UserState extends State<UserPage> {

  User? user;
  List<Review> reviews = [];
  int count = 0;
  double revs = 0;
  bool first = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
        print(user);
        if(!first) {
           getData();
          first = true;
        }
       return Scaffold(
         appBar: AppBar(backgroundColor: Colors.brown[200],title: const Text("Профиль"),),
         body:
         ((user==null || (user?.isAnonymous ?? false)) ? buildEmpty() : buildNotEmpty()),
       );
  }

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
  void getData() async {

    FirebaseFirestore.instance.collection("main").doc("reviews")
        .withConverter(fromFirestore: ReviewList.fromFirestore, toFirestore:(ReviewList list, _) => list.toFirestore())
        .get().then((value)  {
      var list = (value.data() ?? ReviewList(list: [])) as ReviewList;
      setState(() {
        reviews = list.list;
        for(Review i in reviews) {
          if(i.phone1==user!.photoURL) {
            count++;
            revs += (i.count+1);
          }
        }
        if(count!=0) revs = (revs/count);
      });
    });
  }

  Widget buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
     crossAxisAlignment: CrossAxisAlignment.center,
     children: [
       Container(
         alignment: Alignment.center,
         padding: const EdgeInsets.symmetric(horizontal: 20),
         child: const Text("Войдите или зарегистрируйтесь, чтобы пользоваться всеми функциями",
          textAlign: TextAlign.center,),
       ),
       const SizedBox(height: 40,),
       Center(
         child: Column(
           children: [
             ElevatedButton(onPressed: () async {
               await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SignInPage()));
               setState(() {});
             }, child: const Text("Войти ")),
             ElevatedButton(onPressed: () async {
               await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>RegPage()));
               setState(() {});
             }, child: const Text("Зарегистрироваться")),
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
         )
       ),
     ],
    );
  }
  var colors = [Colors.brown[200], Colors.blue, Colors.red, Colors.yellowAccent, Colors.amber, Colors.purple, Colors.lightGreenAccent, Colors.tealAccent, Colors.deepOrangeAccent];

  Widget buildNotEmpty() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(top: 20,left: 30,right: 30,bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(((user?.displayName ?? "Пользователь").split(' ')[0]),
                                  style: const TextStyle(fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              )
                            ],
                          ),
                          if(count>0) Container(
                            child:  count>0 ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(sprintf('%1.1f',[revs])),
                                Container(
                                  height: 30,
                                  width: 70,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: getStars(),
                                ),
                                Text("$count отзывов")
                              ],
                            ) : Text("Нет отзывов"),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: colors[Random().nextInt(colors.length)],
                        radius: 40,
                        child: Center(
                          child: Text(
                            ((user?.displayName ?? "Пользователь").toUpperCase().isEmpty ? "П" : (user?.displayName ?? "Пользователь").toUpperCase())[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  )
              ),
              Container(
                padding: EdgeInsets.only(left: 30,right: 30,bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.phone),
                    SizedBox(width: 30,),
                    Text(user?.photoURL ?? "")
                  ],
                ),
              ),
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.white,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text("Редактировать профиль",style: TextStyle(color: Colors.blue),),
                  ),
                ),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (context)=> EditUser()));
                  setState(() {
                    user = FirebaseAuth.instance.currentUser;
                  });
                },
              ),
              const SizedBox(height: 10,),
              Container(
                child: ElevatedButton(onPressed: () async {
                  launchTelegram();
                }, child: Container(
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
                margin: EdgeInsets.symmetric(horizontal: 10),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            child: Container(
              width: double.infinity,
              height: 60,
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text("Выйти",style: TextStyle(color: Colors.blue),),
              ),
            ),
            onTap: () async {
             await FirebaseAuth.instance.signOut();
             setState(() {
               user = null;
             });
            },
          ),
        )
      ],
    );
  }

  Widget getStars() {
    return ListView.builder(itemBuilder: (ctx,ind) {
      return Icon(Icons.star, size: 10, color: Colors.amber,);
    },
      shrinkWrap: false,
      scrollDirection: Axis.horizontal,
      itemCount: revs.round(),
    );
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