
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

    String? filename;
    var firestore = FirebaseFirestore.instanceFor(app: Firebase.app());
  TextEditingController title = TextEditingController();
  TextEditingController desc = TextEditingController();
    TextEditingController price = TextEditingController();
    TextEditingController address = TextEditingController();
  Ads? ads;
  bool first = true;
  bool fromFile = false;
  bool loading = false;
  String? url;
    
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
        url = ads!.photoUrl;
        FirebaseStorage.instance.ref().child(ads!.photoUrl+".jpg").getDownloadURL().then((value) {
          setState(() {
            filename = value;
          });
        });
      }
    }
    
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
                    if(list.list[i].photoUrl==ads!.photoUrl) {
                      list.list.removeAt(i);
                      break;
                    }
                  }
                  FirebaseFirestore.instance.collection("main").doc("ads")
                  .set(list.toFirestore()).then((value) => {
                      FirebaseStorage.instance.ref().child(ads!.photoUrl+".jpg")
                      .delete().then((value) => {
                        Navigator.of(context).pop()
                    })
                  });
                });
              },
            )
          ],
      ),
      body: loading ? isLoading() : SingleChildScrollView(

        child: Column(
          children: [

            if(filename==null) GestureDetector(
              child: Container(
                color: Colors.grey,
                width: double.infinity,
                height: 200,
                margin: EdgeInsets.only(top: 20,left: 20,right: 20),
                child: Icon(Icons.add_a_photo_outlined, size: 60,),
              ),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                // if no file is picked
                if (result == null) return;
                setState(() {
                  filename = result.paths[0];
                  fromFile = true;
                  url = filename;
                });
              },
            )
            else Container(
              margin: EdgeInsets.only(top: 20,left: 20,right: 20),
              child: Stack(
                children: [
                  fromFile ? Image.file(File(filename!)) : Image.network(filename!),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(onPressed: (){
                        setState(() {
                          filename = null;
                          fromFile = false;
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
            ),
            Container(
             margin: EdgeInsets.all(20),
             color: Colors.grey[300],
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Название",style: TextStyle(color: Colors.amber),)),
               maxLines: 1,
                maxLength: 60,
                autofocus: true,
                controller: title,
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              color: Colors.grey[300],
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Цена",style: TextStyle(color: Colors.amber),),
                  suffixText: getCurrency()
                ),
                keyboardType: TextInputType.number,
                maxLines: 1,
                maxLength: 60,
                autofocus: true,
                controller: price,
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(5),
              color: Colors.grey[300],
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Адрес",style: TextStyle(color: Colors.amber),)),
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                maxLength: 100,
                autofocus: true,
                controller: address,
              ),
            ),
            Container(
              height: 400,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(5),
              color: Colors.grey[300],
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Описание",style: TextStyle(color: Colors.amber),)),
                keyboardType: TextInputType.multiline,
                maxLines: 100,
                maxLength: 300,
                autofocus: true,
                controller: desc,
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                  onPressed: () async {
                  if(filename!=null && title.text.isNotEmpty && price.text.isNotEmpty && address.text.isNotEmpty) {
                    setState(() {
                      loading = true;
                    });
                    final ref = firestore.collection("main")
                        .doc("ads")
                        .withConverter(fromFirestore: AdsList.fromFirestore, toFirestore:(AdsList list, _) => list.toFirestore());
                      ref.get().then((value) {
                    var list = value.data() ?? AdsList(list: []);
                    var date = DateTime.now();
                    var formatter = DateFormat('dd.MM.yyyy HH:mm');
                    var ads1 = Ads(
                        title: title.text,
                        desc: desc.text,
                        author: FirebaseAuth.instance.currentUser!.displayName ?? "Пользователь",
                        photoUrl: UniqueKey().hashCode.toString(),
                        email: FirebaseAuth.instance.currentUser!.phoneNumber!,
                        price: price.text.toString(),
                        date: formatter.format(date),
                        address: address.text
                    );
                    if(ads==null) list.list.add(ads1);
                    else {
                      ads!.date = ads1.date;
                      ads!.address = address.text.toString();
                      ads!.title = title.text.toString();
                      ads!.price = price.text.toString();
                      ads!.desc = desc.text.toString();
                      for(int i = 0;i<list.list.length;i++) {
                        if(list.list[i].photoUrl==ads!.photoUrl) {
                          list.list[i] = ads!;
                          break;
                        }
                      }
                    }
                    FirebaseFirestore.instance.collection("main").doc("ads").set(list.toFirestore()).then((value) =>
                    {
                      if(ads==null) {
                        FirebaseStorage.instance.ref().child("${ads1.photoUrl}.jpg").putFile(File(filename!)).then((p0) =>
                        {
                         // Navigator.of(context).pop()
                        })
                      } else {
                        if(url!=ads!.photoUrl) {
                          print("$filename ${ads!.photoUrl}"),
                          FirebaseStorage.instance.ref().child("${ads!.photoUrl}.jpg").putFile(File(filename!)).then((p0) =>
                          {
                            //Navigator.of(context).pop()
                          })
                        }
                      },
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
      return Center(
        child: CircularProgressIndicator(),
      );
    }
}