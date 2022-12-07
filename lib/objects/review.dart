
class Review {
  String phone1, phone2, name1, name2, text;
  int count;
  Review({
    required this.phone1, required this.phone2,
    required this.name1, required this.name2,
    required this.text, required this.count
  });

  factory Review.fromFirestore(
        Map<String, dynamic> data
      ) {
    return Review(
      phone1: data['phone1'],
      phone2: data['phone2'],
      name1: data['name1'],
      name2: data['name2'],
      text: data['text'],
      count: data['count'],
    );
  }

  Map<String,dynamic> toFirestore() {
    return {
      'phone1': phone1,
      'phone2': phone2,
      'name1': name1,
      'name2': name2,
      'text': text,
      'count': count,
    };
  }
}