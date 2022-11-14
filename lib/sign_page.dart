
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {

  String method;

  SignInPage({required this.method});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SignInState();
  }

}

class SignInState extends State<SignInPage> {

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController sur = TextEditingController();
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
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Введите телефон",
                    fillColor: Colors.black12,
                    filled: true
                ),
                controller: email,
              ),
              padding: EdgeInsets.symmetric(horizontal: 40,vertical: 30),
            ),
            if(codesent)  Container(
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Введите код",
                    fillColor: Colors.black12,
                    filled: true
                ),
                controller: pass,
              ),
              padding: EdgeInsets.symmetric(horizontal: 40,vertical: 30),
            ),
            SizedBox(height: 35,),
            ElevatedButton(onPressed: () async {
              if(codesent) {
                setState(() {
                  loading = true;
                });
                final tmp = await FirebaseAuth
                    .instance
                    .signInWithCredential(PhoneAuthProvider.credential(verificationId: _id, smsCode: pass.text));
                if(tmp.user!.displayName==null) await tmp.user!.updateDisplayName("Пользователь");
                Navigator.of(context).pop();
              } else {
                _submitPhoneNumber();
                setState(() {
                  codesent = true;
                });
              }
            }, child: SizedBox(child: Text("Войти или зарегистрироваться",textAlign: TextAlign.center,),width: 250,)),
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