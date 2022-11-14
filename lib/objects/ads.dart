
import 'package:cloud_firestore/cloud_firestore.dart';

class Ads {

 String email, title, desc, author, photoUrl, price, date, address;

 Ads({
   required this.email, required this.title, required this.desc,
   required this.author, required this.photoUrl,
   required this.price, required this.date,
   required this.address
 });

 factory Ads.fromFirestore(
      Map<String,dynamic> data
     ) {
  return Ads(email: data['email'],
       title:data['title'],
       desc: data['desc'],
       author: data['author'],
       photoUrl: data['photoUrl'],
        date: data['date'],
        price: data['price'],
    address: data['address']
   );
 }

 Map<String,dynamic> toFirestore() {
   return {
     'email': email,
     'title': title,
     'desc': desc,
     'author': author,
     'photoUrl': photoUrl,
     'date': date,
     'price':price,
     'address':address
   };
 }


}