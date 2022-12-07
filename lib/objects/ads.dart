
import 'package:cloud_firestore/cloud_firestore.dart';

class Ads {

 String email, title, desc, author, price, date, address;
 List<String> photos;
 int id, last;

 Ads({
   required this.email, required this.title, required this.desc,
   required this.author, required this.photos,
   required this.price, required this.date,
   required this.address, required this.id,
   required this.last
 });

 factory Ads.fromFirestore(
      Map<String,dynamic> data
     ) {
  return Ads(email: data['email'],
       title:data['title'],
       desc: data['desc'],
       author: data['author'],
       photos: List<String>.from(data['photoUrl']),
        date: data['date'],
        price: data['price'],
    address: data['address'],
    id: data['id'],
    last: data['last']
   );
 }

 Map<String,dynamic> toFirestore() {
   return {
     'email': email,
     'title': title,
     'desc': desc,
     'author': author,
     'photoUrl': photos,
     'date': date,
     'price':price,
     'address':address,
     'id': id,
     'last': last
   };
 }


}