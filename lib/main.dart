import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youlearn/assets/themeProvider.dart';
import 'package:youlearn/pages/splashScreen.dart';
import './pages/authScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './pages/courseScreen.dart';
import './pages/categoryScreen.dart';
import 'package:flutter/services.dart';
import 'assets/colors.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Firestore dbRef = Firestore.instance;
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;
  bool signedIn = false;
  bool loading = true;
  String userUid;

  @override
  void initState() { 
    Timer(Duration(seconds: 3), timeDelay); 
    super.initState();
  }

  void timeDelay(){
    checkAuthStatus().then((authState){
      if (authState){
        userUid = user.uid;
      }
      getCurrentAppTheme().then((value){
        setState(() {
          signedIn = authState;
          loading = false;
        });
      });
    });
  }

  Future<bool> checkAuthStatus() async{
    user = await auth.currentUser();
    return user == null ? false : true;
  }

  Future<void> getCurrentAppTheme() async{
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            home: loading ? SplashScreen() : signedIn ? HomePage(dbRef.collection("Users").document(userUid)) : AuthScreen() 
          );
        }
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final DocumentReference _documentReference;
  HomePage(this._documentReference);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Firestore dbRef = Firestore.instance;
  bool hasCategories = false;
  bool loading = true;

  @override
  void initState() {
    checkForCategories(widget._documentReference).then((categoryStatus){
      setState(() {
        hasCategories = categoryStatus;
        loading = false;
      });
    });
    super.initState();
  }

  Future<bool> checkForCategories(DocumentReference documentReference) async{
    int length = await documentReference.collection("Categories").getDocuments().then((value) => value.documents.length);
    if(length > 0){
      return true;
    }
    else{
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Scaffold(
      body: Center(
        child: CircularProgressIndicator()
      ),
    ) : hasCategories ? CourseScreen(widget._documentReference) : CategoryScreen(widget._documentReference);
  }
}
