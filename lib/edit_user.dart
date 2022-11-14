
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditUser extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditUserState();
  }

}
class EditUserState extends State<EditUser> {

  TextEditingController name = TextEditingController();
  TextEditingController sur = TextEditingController();
  bool first = true;
  late User user;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(first) {
      user = FirebaseAuth.instance.currentUser!;
      first = false;
      name.text = user.displayName!.trim().split(" ")[0];
      if(user.displayName!.trim().split(" ").length>1) sur.text = user.displayName!.trim().split(" ")[1];
    }
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.brown[200],),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Введите имя",
                  fillColor: Colors.black12,
                  filled: true
              ),
              controller: name,
            ),
            padding: EdgeInsets.symmetric(horizontal: 40,vertical: 30),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Введите фамилию",
                  fillColor: Colors.black12,
                  filled: true
              ),
              controller: sur,
            ),
            padding: EdgeInsets.symmetric(horizontal: 40,vertical: 30),
          ),
          ElevatedButton(onPressed: () async {
           await user.updateDisplayName(name.text+" "+sur.text);
           Navigator.of(context).pop();
          }, child: Text("Сохранить изменения"))
        ],
      ),
    );
  }

}