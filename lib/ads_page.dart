
import 'package:Donsale/chat_page.dart';
import 'package:Donsale/db/db_helper.dart';
import 'package:Donsale/db/fav_item.dart';
import 'package:Donsale/objects/ads.dart';
import 'package:Donsale/objects/ads_list.dart';
import 'package:Donsale/objects/chat.dart';
import 'package:Donsale/objects/chat_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

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
  List<FavItem> favs = [];
  Map<String, String> urls = {};
  bool first = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(!first) {
      ads = widget.ads;
      getData();
      first = false;
    }
    if(!urls.containsKey(ads.photoUrl)) {
      FirebaseStorage.instance.ref().child(ads.photoUrl+".jpg").getDownloadURL().then((value) {
        setState(() {
          urls[ads.photoUrl] = value;
        });
      });
    }
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.brown[200],
        actions: [
          IconButton(
            onPressed: () async {
              if(contains(ads.photoUrl)) {
                await DBProvider.db.removeFromFavs(ads.photoUrl);
                setState(() {
                  for(FavItem i in favs) {
                    if(i.id_ads==ads.photoUrl) {
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
                var tmp = FavItem(id: id, id_ads: ads.photoUrl);
                setState(() {
                  favs.add(tmp);
                });
                DBProvider.db.insert(tmp);
              }
            }, icon: contains(ads.photoUrl)
              ? Icon(Icons.favorite, color: Colors.red,) : Icon(Icons.favorite_border),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              urls.containsKey(ads.photoUrl) ?
              Image.network(
                urls[ads.photoUrl]!,
                fit: BoxFit.scaleDown,
              ) :
              const CircularProgressIndicator(),
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
                        if(i.ads.photoUrl==ads.photoUrl) {
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
              Text(ads.desc)
            ],
          ),
        ),
      ),
    );

  }
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
  }

  Future<Widget> _getImage(BuildContext context, String ind) async {
    Widget m;
    var st = (await FirebaseStorage.instance.ref(ind+".jpg").getDownloadURL().onError((error, stackTrace) {
      setState(() {
        m = FlutterLogo();
      });
      return "";
    }).onError((error, stackTrace) {
      setState(() {
        m = FlutterLogo();
      });
      return "";
    })
    );
    m = Image.network(
      st,
      fit: BoxFit.scaleDown,
      width: double.infinity,
    );
    return m;
  }
  String getCurrency() {
    var format = NumberFormat.simpleCurrency(locale: "ru");
    return format.currencySymbol;
  }
}