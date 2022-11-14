
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

class FavoritesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FavoritesState();
  }

}
class FavoritesState extends State<FavoritesPage> {

  List<Ads> data = [];
  List<FavItem> favs = [];
  Map<String, String> urls = {};
  bool first = false;
  User? user = FirebaseAuth.instance.currentUser;
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(!first) {
      getData();
      first = false;
    }
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.brown[200],title: Text('Избранное'),),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(itemBuilder: (context,ind) {
          return buildItem(context, ind);
        },
          itemCount: data.length,
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
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
        data = data.takeWhile((value) => contains(value.photoUrl) && (user!=null && value.email!=(user!.phoneNumber ?? "") || user==null)).toList();
      });
    });
    var fav = await DBProvider.db.getAll();
    setState(() {
      favs = fav!;
    });
  }
  bool contains(String id) {
    for(FavItem i in favs) {
      if(i.id_ads==id) return true;
    }
    return false;
  }
  Widget buildItem(BuildContext context, int ind) {
    if(!urls.containsKey(data[ind].photoUrl)) {
      FirebaseStorage.instance.ref().child(data[ind].photoUrl+".jpg").getDownloadURL().then((value) {
        setState(() {
          urls[data[ind].photoUrl] = value;
        });
      });
    }
    return Container(
        padding: EdgeInsets.all(1),
        child: GestureDetector(
          onTap: (){
            if(user!=null && data[ind].email!=user!.phoneNumber! || user==null) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AdsPage(ads: data[ind])));
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>NewPage(ads: data[ind])));
            }
          },
          child: Card(
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  urls.containsKey(data[ind].photoUrl) ?
                  Image.network(
                    urls[data[ind].photoUrl]!,
                    fit: BoxFit.scaleDown,
                  ) :
                  const CircularProgressIndicator(),
                  Text(data[ind].title,textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 3,),
                  Text("${data[ind].price} ${getCurrency()}",textAlign: TextAlign.start,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data[ind].date),
                      if(user!=null && data[ind].email!=user!.phoneNumber! || user==null) IconButton(
                        onPressed: () async {
                          if(contains(data[ind].photoUrl)) {
                            await DBProvider.db.removeFromFavs(data[ind].photoUrl);
                            setState(() {
                              for(FavItem i in favs) {
                                if(i.id_ads==data[ind].photoUrl) {
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
                            var tmp = FavItem(id: id, id_ads: data[ind].photoUrl);
                            setState(() {
                              favs.add(tmp);
                            });
                            DBProvider.db.insert(tmp);
                          }
                        }, icon: contains(data[ind].photoUrl)
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
  Future<Widget> _getImage(BuildContext context, int ind) async {
    Widget m;
    var st = (await FirebaseStorage.instance.ref(data[ind].photoUrl+".jpg").getDownloadURL().catchError((e) {
      m = FlutterLogo();
      return m;
    }));
    m = Image.network(
      st,
      fit: BoxFit.scaleDown,
    );
    return m;
  }
  @override
  void dispose() {
    data = [];
    super.dispose();
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
  String getCurrency() {
    var format = NumberFormat.simpleCurrency(locale: "ru");
    return format.currencySymbol;
  }
}