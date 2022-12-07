
import 'dart:async';
import 'package:Donsale/ads_page.dart';
import 'package:Donsale/db/db_helper.dart';
import 'package:Donsale/db/fav_item.dart';
import 'package:Donsale/new_page.dart';
import 'package:Donsale/objects/ads.dart';
import 'package:Donsale/objects/ads_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeState();
  }

}

class HomeState extends State<HomePage> {

  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Главная');
  List<Ads> data = [];
  List<FavItem> favs = [];
  bool first = false;
  TextEditingController search = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(!first) {
      getData();
      first = false;
    }
   return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        backgroundColor: Colors.brown[200],
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (customIcon.icon == Icons.search) {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    title: TextField(
                      controller: search,
                      decoration: InputDecoration(
                        hintText: 'Поиск',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      onChanged: (s) {
                        setState(() {
                          var tmp = <Ads>[];
                          for(Ads i in list.list) {
                            if(i.title.contains(search.text.toString())) tmp.add(i);
                          }
                          data = tmp;
                          print(data.length);
                        });
                      },
                    ),
                  );
                } else {
                  search.text = "";
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Поиск');
                  data = list.list;
                }
              });
            },
            icon: customIcon,
          )
        ],
      ),
     body: GridView.builder(
       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
        crossAxisSpacing: 5,
         mainAxisSpacing: 5,
         childAspectRatio: 0.7
       ),
       itemBuilder: (_, index) {
         return buildItem(_, index);
       },
       shrinkWrap: false,
       itemCount: data.length,

     ),
     backgroundColor: Colors.grey[100],
   );
  }


  @override
  void initState() {
    super.initState();
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

  var list;
  void getData() async {
    final ref = FirebaseFirestore.instance.collection("main")
        .doc("ads")
        .withConverter(fromFirestore: AdsList.fromFirestore, toFirestore:(AdsList list, _) => list.toFirestore());
    ref.get().then((value) {
      list = (value.data() ?? AdsList(list: []));
      setState(() {
        var tmp = <Ads>[];
        for(Ads i in list.list) {
          if(i.title.contains(search.text.toString())) tmp.add(i);
        }
        data = tmp;
      });
    });
    var fav = await DBProvider.db.getAll();
    setState(() {
      favs = fav!;
    });
  }

  Widget buildItem(BuildContext context, int ind) {
    return Container(
      child: GestureDetector(
        onTap: (){
          if(user!=null && data[ind].email!=user!.photoURL! || user==null) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AdsPage(ads: data[ind])));
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>NewPage(ads: data[ind])));
          }
        },
        child: Card(
          color: Colors.white,
          child: Container(
           padding: EdgeInsets.only(left: 5,right: 5,top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child:  Image.network(
                    data[ind].photos[0],
                    fit: BoxFit.scaleDown,
                    height: 160,
                  ),
                ),
                SizedBox(height: 20,),
                Text(data[ind].title,textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.bold),),
                Text("${data[ind].price} ${getCurrency()}",textAlign: TextAlign.start,),
                if(!(user!=null && data[ind].email!=(user!.photoURL ?? "") || user==null)) SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data[ind].date),
                    if(user!=null && data[ind].email!=(user!.photoURL ?? "") || user==null) IconButton(
                      onPressed: () async {
                        if(contains(data[ind].id.toString())) {
                          await DBProvider.db.removeFromFavs(data[ind].id.toString());
                          setState(() {
                            for(FavItem i in favs) {
                              if(i.id_ads==data[ind].photos[0]) {
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
                          var tmp = FavItem(id: id, id_ads: data[ind].id.toString());
                          setState(() {
                            favs.add(tmp);
                          });
                          DBProvider.db.insert(tmp);
                        }
                      }, icon: contains(data[ind].id.toString())
                        ? Icon(Icons.favorite, color: Colors.red,) : Icon(Icons.favorite_border),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }
  bool contains(String id) {
    for(FavItem i in favs) {
      if(i.id_ads==id) return true;
    }
    return false;
  }
  Future<Widget> _getImage(BuildContext context, int ind) async {
   Widget m;
   var st = (await FirebaseStorage.instance.ref().child("${data[ind].photos[0]}.jpg").getDownloadURL().onError((error, stackTrace) {
     print("error 1");
     setState(() {
       m = FlutterLogo();
     });
     return "";
   }).onError((error, stackTrace) {
     print('error 2');
     setState(() {
       m = FlutterLogo();
     });
     return "";
   })
   );
    m = Image.network(
     st,
     fit: BoxFit.scaleDown,
      height: 60,
   );
    return m;
  }
  @override
  void dispose() {
    data = [];
    super.dispose();
  }
  String getCurrency() {
    var format = NumberFormat.simpleCurrency(locale: "ru");
    return format.currencySymbol;
  }
}