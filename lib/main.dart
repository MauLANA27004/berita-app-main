import 'package:berita_app/admin/create_news_page.dart';
import 'package:berita_app/auth/signin_page.dart';
import 'package:berita_app/firebase_options.dart';
import 'package:berita_app/helper/auth_helper.dart';
import 'package:berita_app/user/bookmarked_widget.dart';
import 'package:berita_app/user/list_news.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Detik.com",
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Detik.com", style: TextStyle(fontSize: 24)),
            actions: [
              Builder(
                builder: (context) {
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    return InkWell(
                      child: const Column(
                        children: [Icon(Icons.login), Text("login")],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(),
                          ),
                        );
                      },
                    );
                  } else {
                    return InkWell(
                      child: Column(
                        children: [Icon(Icons.logout), Text("logout")],
                      ),
                      onTap: () {
                        AuthHelper.signOut(context);
                      },
                    );
                  }
                },
              ),
              Padding(padding: EdgeInsets.only(right: 20))
            ],
          ),
          body: FutureBuilder<String?>(
            future: AuthHelper.getUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              String? role = snapshot.data;

              return PersistentTabView(
                navBarBuilder: (navBarConfig) =>
                    Style1BottomNavBar(navBarConfig: navBarConfig),
                tabs: [
                  PersistentTabConfig(
                    screen: ListNews(),
                    item: ItemConfig(
                      icon: Icon(Icons.home),
                      title: "Home",
                    ),
                  ),
                  PersistentTabConfig(
                    screen: BookmarkedWidget(),
                    item: ItemConfig(
                      icon: Icon(Icons.bookmark),
                      title: "Favorite",
                    ),
                  ),
                  if (role == 'admin')
                    PersistentTabConfig(
                      screen: CreateNewsPage(),
                      item: ItemConfig(
                        icon: Icon(Icons.add),
                        title: "Create news",
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
