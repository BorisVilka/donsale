
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegPage extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RegState();
  }

}

class RegState extends State<RegPage> {

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController sur = TextEditingController();
  TextEditingController num = TextEditingController();
  late String _id;
  bool codesent = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.brown[200],),
      body: loading ? isLoading() : SingleChildScrollView(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 20),
              child: TextField(
                decoration: InputDecoration(
                   hintText: "Введите email",
                    fillColor: Colors.black12,
                    filled: true,
                    errorText: email.text.isNotEmpty ? null : "Введите email"
                ),
                controller: email,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: true,
                autocorrect: true,
                onChanged: (s) {setState(() {});},
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                    hintText: "Введите телефон",
                    fillColor: Colors.black12,
                    filled: true,
                    errorText: num.text.isNotEmpty ? null : "Введите номер телефона"
                ),
                controller: num,
                keyboardType: TextInputType.phone,
                enableSuggestions: true,
                autocorrect: true,
                  onChanged: (s) {setState(() {});},
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 10),
              child: TextField(
                decoration:InputDecoration(
                    hintText: "Введите имя",
                    fillColor: Colors.black12,
                    filled: true,
                    errorText: name.text.isNotEmpty ? null : "Введите имя"
                ),
                controller: name,
                keyboardType: TextInputType.name,
                enableSuggestions: true,
                autocorrect: true,
                onChanged: (s) {setState(() {});},
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 20),
              child: TextField(
                decoration: InputDecoration(
                    hintText: "Введите фамилия",
                    fillColor: Colors.black12,
                    filled: true,
                    errorText: sur.text.isNotEmpty ? null : "Введите фамилию"
                ),
                controller: sur,
                keyboardType: TextInputType.name,
                enableSuggestions: true,
                autocorrect: true,
                onChanged: (s) {setState(() {});},
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                decoration: InputDecoration(
                    hintText: "Введите пароль",
                    fillColor: Colors.black12,
                    filled: true,
                    errorText: pass.text.isNotEmpty ? null : "Введите пароль"
                ),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: pass,
                onChanged: (s) {setState(() {});},
              ),
            ),
            SizedBox(height: 10,),
            Text("Пароль должен быть длиннее 6 символов"),
            const SizedBox(height: 35,),
            ElevatedButton(onPressed: () async {
                if(pass.text.isNotEmpty && email.text.isNotEmpty && num.text.isNotEmpty && name.text.isNotEmpty && sur.text.isNotEmpty) {
                  setState(() {
                    loading = true;
                  });
                  try {
                    var usCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text.trim(), password: pass.text.trim());
                    await usCred.user!.updatePhotoURL(num.text);
                    await usCred.user!.updateDisplayName("${name.text.trim()} ${sur.text.trim()}");
                    Navigator.of(context).pop();
                  } on FirebaseAuthException catch(e) {
                    print(e.code);
                    if(e.code=="weak-password") {
                      Fluttertoast.showToast(
                          msg: "Плохой пароль",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0
                      );
                    }
                    else if(e.code=="email-already-in-use") {
                      Fluttertoast.showToast(
                          msg: "Такой email существует",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0
                      );
                    }
                    setState(() {
                      loading = false;
                    });
                  }
                }
            }, child: const SizedBox(width: 250,child: Text("Зарегистрироваться",textAlign: TextAlign.center,),)),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPhoneNumber() async {
    String phoneNumber = email.text.toString().trim();
    print(phoneNumber);

    void verificationCompleted(AuthCredential phoneAuthCredential) {
      print('verificationCompleted');
      //this._phoneAuthCredential = phoneAuthCredential;
      print(phoneAuthCredential);
    }

    void verificationFailed(FirebaseAuthException error) {
      //exception???
      print(error);
    }

    void codeSent(String verificationId, int? code) async {
      print('codeSent');
      _id = verificationId;
      //await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: _controller.text));
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
    }

    await FirebaseAuth.instance.verifyPhoneNumber(

      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,
      timeout: const Duration(milliseconds: 10000),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }
  Widget isLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}