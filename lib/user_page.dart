

import 'package:Donsale/edit_user.dart';
import 'package:Donsale/reg_page.dart';
import 'package:Donsale/sign_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class UserPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return UserState();
  }
  
}

class UserState extends State<UserPage> {
  
  User? user;
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
        print(user);
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
           ],
         )
       ),
     ],
    );
  }
  
  Widget buildNotEmpty() {
    List<Widget> stars = getStars(5);
    stars.insert(0, Padding(padding: const EdgeInsets.only(right: 10),
    child: Text("5.0",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),));
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(top: 20,left: 30,right: 30,bottom: 30),
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
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: stars,
                            ),
                            padding: EdgeInsets.only(bottom: 10),
                          ),
                          Text("Нет отзывов")
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.green,
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
                padding: EdgeInsets.symmetric(horizontal: 30),
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

  List<Widget> getStars(int n) {
    List<Widget> a = [];
    for(int i = 0;i<n;i++) {
      a.add(Icon(Icons.star,color: Colors.amber[700],size: 13,));
    }
    return a;
  }
}