

class Message {

  String txt, phone, name;

  Message({
    required this.txt, required this.phone, required this.name
    });


  factory Message.fromFirestore(
      Map<String,dynamic> data
      ) => Message(txt: data['txt'], phone: data['phone'], name: data['name']);

  Map<String,dynamic> toFirestore() => {
    'txt':txt,
    'name':name,
    'phone':phone
  };
}
