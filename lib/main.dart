

import 'package:Donsale/add_page.dart';
import 'package:Donsale/chats_page.dart';
import 'package:Donsale/favs_page.dart';
import 'package:Donsale/firebase_options.dart';
import 'package:Donsale/home_page.dart';
import 'package:Donsale/user_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
 // if(FirebaseAuth.instance.currentUser==null) await FirebaseAuth.instance.signInAnonymously();
  await FirebaseAppCheck.instance.activate(
    androidDebugProvider: true
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainPage()
     )
  );
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MainState();
  }

}
class MainState extends State<MainPage> {
  int ind = 0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: ind,
          onTap: (ind) {
            setState(() {
              this.ind = ind;
            });
          },
          selectedItemColor: Colors.brown[200],
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, color: Colors.grey,),
              activeIcon: Icon(Icons.home_outlined, color: Colors.brown[200],),
              label: 'Поиск',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, color: Colors.grey,),
              activeIcon: Icon(Icons.favorite, color: Colors.brown[200],),
              label: 'Избранное',
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Center(
                  child: Icon(Icons.add_card,color:Colors.white),
                ),
              ),
              label: 'Объявления',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, color: Colors.grey,),
              activeIcon: Icon(Icons.chat, color: Colors.brown[200],),
              label: 'Сообщения',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.grey,),
              activeIcon: Icon(Icons.person, color: Colors.brown[200],),
              label: 'Профиль',
            ),
          ],
        ),
        body: children[ind]
      ),
    );
  }
  var children = [
    HomePage(),
    FavoritesPage(),
    AddPage(),
    ChatsPage(),
    UserPage(),
  ];
}