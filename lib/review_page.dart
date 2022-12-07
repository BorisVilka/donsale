

import 'package:Donsale/objects/chat.dart';
import 'package:Donsale/objects/review.dart';
import 'package:Donsale/objects/review_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {

  Chat chat;
  ReviewPage({required this.chat});
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
   return ReviewState();
  }
  
  
}

class ReviewState extends State<ReviewPage> {
  
  late Chat chat;
  TextEditingController desc = TextEditingController();
  int count = -1;
  User user = FirebaseAuth.instance.currentUser!;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
  }
  Widget isLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.brown[200]),
      body: loading ? isLoading() : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Оцените продавца",style:  TextStyle(fontSize: 24),),
              Container(
                alignment: Alignment.center,
                height: 100,
                child: ListView.builder(itemBuilder: (ctx,ind){
                  return Container(
                    height: 50,
                    child: GestureDetector(
                        onTap: (){
                          setState(() {
                            count = ind;
                          });
                        },
                      child: Icon(Icons.star, size: 50, color: ind<=count ? Colors.amber : Colors.grey,),
                    ),
                  );
                },
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
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
                    errorText: desc.text.isNotEmpty ? null : "Введите текст",
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
                margin: EdgeInsets.only(bottom: 10,left: 20,right: 20),
                width: double.infinity,
                child: ElevatedButton(onPressed: (){
                  if(desc.text.isNotEmpty) {
                    setState(() {
                      loading = true;
                    });
                    FirebaseFirestore.instance.collection("main").doc("reviews")
                        .withConverter(fromFirestore: ReviewList.fromFirestore, toFirestore:(ReviewList list, _) => list.toFirestore())
                        .get().then((value)  {
                          var list = (value.data() ?? ReviewList(list: [])) as ReviewList;
                          list.list.add(Review(
                              phone1: chat.email1,
                              phone2: chat.email2,
                              name1: chat.ads.author,
                              name2: user.displayName!,
                              text: desc.text,
                              count: count
                          ));
                          FirebaseFirestore.instance.collection("main").doc("reviews").set(list.toFirestore()).then((value) {
                            Navigator.of(context).pop(count);
                          });
                    });
                  }
                }, child: Text("Оставить отзыв")),
              )
            ],
          ),
        ),
      ),
    );
  }
  
}