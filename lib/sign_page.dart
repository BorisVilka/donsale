
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignInPage extends StatefulWidget {

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
              padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 30),
              child: TextField(
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Введите email",
                    fillColor: Colors.black12,
                    filled: true
                ),
                controller: email,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 30),
              child: TextField(
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Введите пароль",
                    fillColor: Colors.black12,

                    filled: true
                ),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: pass,
              ),
            ),
            const SizedBox(height: 35,),
            ElevatedButton(onPressed: () async {
              if(pass.text.isNotEmpty && email.text.isNotEmpty) {
                setState(() {
                  loading = true;
                });
                try {
                  var usCred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: pass.text.trim());
                  Navigator.of(context).pop();
                } on FirebaseAuthException catch(e) {
                  if (e.code == 'user-not-found') {
                    Fluttertoast.showToast(
                        msg: "Пользователь не найден",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0
                    );
                  } else if (e.code == 'wrong-password') {
                    Fluttertoast.showToast(
                        msg: "Неверный пароль",
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
            }, child: const SizedBox(width: 250,child: Text("Войти",textAlign: TextAlign.center,),)),
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