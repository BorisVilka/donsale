
import 'package:Donsale/objects/ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdsList {

  List<Ads> list;

  AdsList({required this.list});

  factory AdsList.fromFirestore(
      DocumentSnapshot<Map<String,dynamic>> snapshot,
      SnapshotOptions? options
      ) {
      var data = snapshot.data();
      return AdsList(
          list: List<Ads>.from(((data?['list'] ?? []) as List<dynamic>).map((e) => Ads.fromFirestore(e)).toList())
      );
  }


  Map<String,dynamic> toFirestore() {
    return {
      'list': List<dynamic>.from(list.map((e) => e.toFirestore())),
    };
  }
}