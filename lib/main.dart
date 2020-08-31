import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youlearn/assets/themeProvider.dart';
import './pages/authScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool signedIn = false;
  bool loading = true;
  String userUid;

  @override
  void initState() {
    checkAuthStatus().then((authState) {
      setState(() {
        signedIn = authState;
        loading = false;
      });
    });
    super.initState();
    getCurrentAppTheme();
  }

  Future<bool> checkAuthStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userUid = prefs.getString('uid');
    if (userUid == null || userUid == "" || userUid == "null") {
      return false;
    } else {
      return true;
    }
  }

  void getCurrentAppTheme() async{
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
            home: loading ? Scaffold(
              body: Center(
                child: CircularProgressIndicator()
              )
            ) : signedIn ? HomePage(dbRef.collection("Users").document(userUid)) : AuthScreen() 
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
