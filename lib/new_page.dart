
import 'dart:io';

import 'package:Donsale/objects/ads.dart';
import 'package:Donsale/objects/ads_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
class NewPage extends StatefulWidget {
  
  Ads? ads;
  
  NewPage({this.ads});
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
     return NewState();
  }

}

class NewState extends State<NewPage> {

    var firestore = FirebaseFirestore.instanceFor(app: Firebase.app());
  TextEditingController title = TextEditingController();
    TextEditingController desc = TextEditingController();
    TextEditingController price = TextEditingController();
    TextEditingController address = TextEditingController();
  Ads? ads;
  bool first = true;
  bool loading = false;
  String? url;
  List<Pair> files = [];
    
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(first) {
      first = false;
      ads = widget.ads;
      if(ads!=null) {
        title.text = ads!.title;
        desc.text = ads!.desc;
        price.text = ads!.price;
        address.text = ads!.address;
        files.addAll(ads!.photos.map((e) => Pair(url: e,fromNet: true)));
      }
    }
    var photos = getPhotos();
    photos.insert(0,  GestureDetector(
      child: Container(
        color: Colors.grey,
        width: 200,
        height: 200,
        margin: EdgeInsets.only(top: 20,left: 20,right: 20),
        child: Icon(Icons.add_a_photo_outlined, size: 60,),
      ),
      onTap: () async {
        final result = await FilePicker.platform.pickFiles(allowMultiple: true);

        // if no file is picked
        if (result == null) return;
        setState(() {
          files.addAll(result.files.map((e) => Pair(url: e.path!, fromNet: false)).toList());
        });
      },
    ));
    return Scaffold(
      appBar: AppBar(title: Text("Добавить объявление"),backgroundColor: Colors.brown[200],
           actions: [
             if(ads!=null) PopupMenuButton(itemBuilder: (context) {
                return [PopupMenuItem(child: Text("Удалить объявление"),value: 2,)];
              },
              onSelected: (d) {
               print("sel");
                final ref = firestore.collection("main")
                    .doc("ads")
                    .withConverter(fromFirestore: AdsList.fromFirestore, toFirestore:(AdsList list, _) => list.toFirestore());
                ref.get().then((value) {
                  var list = value.data() ?? AdsList(list: []);
                  for(int i = 0;i<list.list.length;i++) {
                    if(list.list[i].id==ads!.id) {
                      list.list.removeAt(i);
                      break;
                    }
                  }
                  FirebaseFirestore.instance.collection("main").doc("ads")
                  .set(list.toFirestore()).then((value) => {
                  for(int i = 0;i<ads!.photos.length;i++) {
                    FirebaseStorage.instance.refFromURL(ads!.photos[i]).delete()
                      },
                  Navigator.of(context).pop()
                  });
                });
              },
            )
          ],
      ),
      body: loading ? isLoading() : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(left: 20,top: 20),
              child: Text("Фотографии",style: TextStyle(fontSize: 20),),
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 10),
              height: 200,
               child: ListView(
                 shrinkWrap: false,
                scrollDirection: Axis.horizontal,
                 children: photos,
              ),
            ),
            Container(
             margin: EdgeInsets.all(20),
             color: Colors.grey[300],
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Название",style: TextStyle(color: Colors.amber),),
                    errorText: title.text.isNotEmpty ? null : "Введите название"
                ),
               maxLines: 1,
                maxLength: 60,
                autofocus: true,
                controller: title,
                onChanged: (s) {setState(() {});},
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              color: Colors.grey[300],
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Цена",style: TextStyle(color: Colors.amber),),
                    errorText: price.text.isNotEmpty ? null : "Введите цену",
                  suffixText: getCurrency()
                ),
                keyboardType: TextInputType.number,
                maxLines: 1,
                maxLength: 60,
                autofocus: true,
                controller: price,
                onChanged: (s) {setState(() {});},
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(5),
              color: Colors.grey[300],
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Адрес",style: TextStyle(color: Colors.amber),),
                    errorText: address.text.isNotEmpty ? null : "Введите адрес"
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                maxLength: 100,
                autofocus: true,
                controller: address,
                onChanged: (s) {setState(() {});},
              ),
            ),
            Container(
              height: 400,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(5),
              color: Colors.grey[300],
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Описание",style: TextStyle(color: Colors.amber),),
                    errorText: desc.text.isNotEmpty ? null : "Введите описание"
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 100,
                maxLength: 300,
                autofocus: true,
                controller: desc,
                onChanged: (s) {setState(() {});},
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                  onPressed: () async {
                  if(title.text.isNotEmpty && price.text.isNotEmpty && address.text.isNotEmpty) {
                    setState(() {
                      loading = true;
                    });
                    final ref = firestore.collection("main")
                        .doc("ads")
                        .withConverter(fromFirestore: AdsList.fromFirestore, toFirestore:(AdsList list, _) => list.toFirestore());
                      ref.get().then((value) async {
                    var list = value.data() ?? AdsList(list: []);
                    var date = DateTime.now();
                    var formatter = DateFormat('dd.MM.yyyy HH:mm');
                    var id = UniqueKey().hashCode;
                    var ph = <String>[];
                    var last = ads==null ? 0 : ads!.last;
                    for(int i = 0;i<files.length;i++) {
                      if(!files[i].fromNet) {
                        var s = await FirebaseStorage.instance.ref("ads").child("${ads==null ? id : ads!.id}_$last.jpg").putFile(File(files[i].url));
                        last++;
                        ph.add(await s.ref.getDownloadURL());
                      } else {
                        ph.add(files[i].url);
                      }
                    }
                    var ads1 = Ads(
                        title: title.text,
                        desc: desc.text,
                        author: FirebaseAuth.instance.currentUser!.displayName ?? "Пользователь",
                        id: id,
                        email: FirebaseAuth.instance.currentUser!.photoURL!,
                        price: price.text.toString(),
                        date: formatter.format(date),
                        address: address.text,
                        photos: ph,
                        last: last
                    );
                    if(ads==null) {
                      list.list.add(ads1);
                    } else {
                      for(int i = 0;i<ads!.photos.length;i++) {
                        if(!ph.contains(ads!.photos[i])) {
                          FirebaseStorage.instance.refFromURL(ads!.photos[i]).delete();
                        }
                      }
                      ads!.photos = ph;
                      ads!.date = ads1.date;
                      ads!.address = address.text.toString();
                      ads!.title = title.text.toString();
                      ads!.price = price.text.toString();
                      ads!.desc = desc.text.toString();
                      for(int i = 0;i<list.list.length;i++) {
                        if(list.list[i].id==ads!.id) {
                          list.list[i] = ads!;
                          break;
                        }
                      }
                    }
                    FirebaseFirestore.instance.collection("main").doc("ads").set(list.toFirestore()).then((value) =>
                    {
                      Navigator.of(context).pop()
                    });
                    print("print");
                      });
                    }
                  }, child: Container(
                width: double.infinity,
                child: Text("Добавить",textAlign: TextAlign.center,),
                 )
              ),
            )
          ],
        ),
      )
    );
  }
    String getCurrency() {
      var format = NumberFormat.simpleCurrency(locale: "ru");
      return format.currencySymbol;
    }

    Widget isLoading() {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    Widget buildPhoto(Pair pair, BuildContext ctx) {

      return Container(
        margin: EdgeInsets.only(top: 20,left: 20,right: 20),
        child: Stack(
          children: [
            !pair.fromNet ? Image.file(File(pair.url)) : Image.network(pair.url),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(onPressed: (){
                setState(() {
                  files.remove(pair);
                });
              }, icon:  ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
                child: Container(
                  child: Icon(Icons.cancel_outlined),
                  color: Colors.amber,
                ),
              )
              ),
            )
          ],
        ),
      );
    }

    List<Widget> getPhotos() {
      var list = <Widget>[];
      for(Pair i in files) {
        list.add(buildPhoto(i,context));
      }
      return list;
    }
}
class Pair {
  String url;
  bool fromNet;
  Pair({required this.fromNet, required this.url});
}