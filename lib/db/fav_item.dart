
class FavItem {
  int id;
  String id_ads;

  FavItem({required this.id, required this.id_ads});


  Map<String,dynamic> toJson() => {
    'id':id,
    'id_ads':id_ads
  };
  factory FavItem.fromJson(Map<String,dynamic> data) => FavItem(id: data['id'], id_ads: data['id_ads']);
}