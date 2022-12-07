
import 'dart:math';

import 'package:Donsale/chat_page.dart';
import 'package:Donsale/db/db_helper.dart';
import 'package:Donsale/db/fav_item.dart';
import 'package:Donsale/objects/ads.dart';
import 'package:Donsale/objects/ads_list.dart';
import 'package:Donsale/objects/chat.dart';
import 'package:Donsale/objects/chat_list.dart';
import 'package:Donsale/objects/review.dart';
import 'package:Donsale/objects/review_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:zoom_widget/zoom_widget.dart';

class AdsPage extends StatefulWidget {

  Ads ads;

  AdsPage({required this.ads});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return AdsState();
  }

}

class AdsState extends State<AdsPage> {

  User? user = FirebaseAuth.instance.currentUser;
  late Ads ads;
  List<Ads> data = [];
  List<Review> reviews = [];
  List<FavItem> favs = [];
  bool first = false;
  var ind1 = 0;
  int count = 0;
  double revs = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(!first) {
      ads = widget.ads;
      getData();
      ind1 = Random().nextInt(colors.length);
      first = true;
    }
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.brown[200],
        actions: [
          IconButton(
            onPressed: () async {
              if(contains(ads.id.toString())) {
                await DBProvider.db.removeFromFavs(ads.id.toString());
                setState(() {
                  for(FavItem i in favs) {
                    if(i.id_ads==ads.id.toString()) {
                      setState(() {
                        favs.remove(i);
                      });
                      break;
                    }
                  }
                });
              } else {
                final db = await DBProvider.db.database;
                var table = await db!.rawQuery("SELECT MAX(id)+1 as id FROM MyDraft");
                int id = table.first["id"]==null ? 0 : table.first["id"] as int;
                var tmp = FavItem(id: id, id_ads: ads.id.toString());
                setState(() {
                  favs.add(tmp);
                });
                DBProvider.db.insert(tmp);
              }
            }, icon: contains(ads.id.toString())
              ? Icon(Icons.favorite, color: Colors.red,) : Icon(Icons.favorite_border),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Фотографии",style: TextStyle(fontSize: 20),),
              Container(
                margin: EdgeInsets.only( top: 10),
                height: 200,
                child: ListView.builder(
                  shrinkWrap: false,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx,ind) {
                    return buildPhoto(ads.photos[ind], ctx);
                  },
                  itemCount: ads.photos.length,
                ),
              ),
              SizedBox(height: 15,),
              Text(ads.title, style: TextStyle(fontSize: 20),),
              Padding(padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("${ads.price} ${getCurrency()}", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(ads.address, style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              ),
              if(user!=null) Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    final ref = FirebaseFirestore.instance.collection("main")
                        .doc("chats")
                        .withConverter(fromFirestore: ChatList.fromFirestore, toFirestore:(ChatList list, _) => list.toFirestore());
                    ref.get().then((value) {
                      var list1 = (value.data() ?? ChatList(list: []));
                      var data1 = list1.list;
                      data1 = data1.takeWhile((value) => value.email1==user!.photoURL! || value.email2==user!.photoURL!).toList();
                      Chat? chat;
                      for(Chat i in data1) {
                        if(i.ads.id==ads.id) {
                          chat = i;
                          break;
                        }
                      }
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatPage(ads: ads,chat: chat,)));
                    });
                  },
                  child: Text("Написать"),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    //print(ads.email);
                    UrlLauncher.launchUrl(Uri.parse("tel://${ads.email}"));
                  },
                  child: Text("Позвонить"),
                ),
              ),
              Text(ads.desc),
              const SizedBox(height: 10,),
              Divider(height: 5,color: Colors.grey[700],),
              Container(
                margin: EdgeInsets.only(top: 10),
                color: Colors.grey[300],
                width: 500,
                height: 100,
                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   Container(
                     alignment: Alignment.center,
                     child:  Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(ads.author,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
                         SizedBox(height: 10,),
                         count>0 ? Row(
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
                         ) : Text("Нет отзывов")
                       ],
                     ),
                   ),
                    CircleAvatar(
                      backgroundColor: colors[Random().nextInt(colors.length)],
                      radius: 30,
                      child: Center(
                        child: Text(
                          ((user?.displayName ?? "Пользователь").toUpperCase().isEmpty ? "П" : (user?.displayName ?? "Пользователь").toUpperCase())[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );

  }
  var colors = [Colors.brown[200], Colors.blue, Colors.red, Colors.yellowAccent, Colors.amber, Colors.purple, Colors.lightGreenAccent, Colors.tealAccent, Colors.deepOrangeAccent];
  bool contains(String id) {
    for(FavItem i in favs) {
      if(i.id_ads==id) return true;
    }
    return false;
  }
  var list;
  void getData() async {
    final ref = FirebaseFirestore.instance.collection("main")
        .doc("ads")
        .withConverter(fromFirestore: AdsList.fromFirestore, toFirestore:(AdsList list, _) => list.toFirestore());
    ref.get().then((value) {
      list = (value.data() ?? AdsList(list: []));
      setState(() {
        data = list.list;
      });
    });
    var fav = await DBProvider.db.getAll();
    setState(() {
      favs = fav!;
    });
    FirebaseFirestore.instance.collection("main").doc("reviews")
        .withConverter(fromFirestore: ReviewList.fromFirestore, toFirestore:(ReviewList list, _) => list.toFirestore())
        .get().then((value)  {
      var list = (value.data() ?? ReviewList(list: [])) as ReviewList;
      setState(() {
        reviews = list.list;
        for(Review i in reviews) {
          if(i.phone1==ads.email) {
            count++;
            revs += (i.count+1);
          }
        }
        if(count!=0) revs = (revs/count);
      });
    });
  }

  String getCurrency() {
    var format = NumberFormat.simpleCurrency(locale: "ru");
    return format.currencySymbol;
  }
  Widget buildPhoto(String pair, BuildContext ctx) {
    return Container(
      margin: EdgeInsets.only(top: 20,left: 5,right: 5),
      child:  GestureDetector(
        onTap: (){
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Zoom(
                    backgroundColor: Colors.transparent,
                    initTotalZoomOut: true,
                    child: Image.network(
                      pair,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Image.network(pair),
      )
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
}