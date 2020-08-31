import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool loading = false;
  Firestore dbRef = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<FirebaseUser> signInWithGoogle() async{
    setState(() {
      loading = true;
    });
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleSignInAuthentication.idToken, 
      accessToken: googleSignInAuthentication.accessToken
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return user;
  }

  Future<void> setAuthState(String userUid) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', userUid);
  }

  Future<bool> checkCloudFirestore(String userUid) async{
    final snapShot = await dbRef.collection("Users").document(userUid).get();
    if(snapShot.exists && snapShot != null){
      return true;
    }
    else{
      return false;
    }
  }

  Future<void> updateUserData(FirebaseUser firebaseUser) async{
    await dbRef.collection("Users").document(firebaseUser.uid).setData({
      'name' : firebaseUser.displayName,
      'email' : firebaseUser.email,
      'imageUrl' : firebaseUser.photoUrl
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 30),
                SvgPicture.asset(
                  "./assets/images/Authlogo1.svg",
                  height: 90
                ),
                SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 37,
                      letterSpacing: -1,
                      fontWeight: FontWeight.w600
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "You",
                        style: TextStyle(
                          color: Color(0xFFFF6F00),
                        )
                      ),
                      TextSpan(
                        text: "Learn",
                        style: TextStyle(
                          color: Color(0xFF425066),
                        )
                      )
                    ]
                  )
                ),
                SizedBox(height: 55),
                Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF464646)
                  )
                ),
                SizedBox(height: 10),
                Container(
                  width: 250,
                  child: Text(
                    "Signup or login to explore the courses offered",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.7,
                      wordSpacing: 2,
                      height: 2
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 35),
                Container(
                  width: 190,
                  child: RaisedButton(
                    elevation: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SvgPicture.asset(
                          "./assets/images/GoogleLogo.svg",
                          height: 20,
                        ),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF707070)
                          ),
                        )
                      ],
                    ),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                    onPressed: (){
                      signInWithGoogle().then((user) {
                        setAuthState(user.uid).then((nothing) {
                          checkCloudFirestore(user.uid).then((cloudFirestoreState) {
                            if(cloudFirestoreState){
                              setState(() {
                                loading = false;
                              });
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage(dbRef.collection("Users").document(user.uid))));
                            } 
                            else{
                              updateUserData(user).then((nothing1) {
                                setState(() {
                                  loading = false;
                                });
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage(dbRef.collection("Users").document(user.uid))));
                              });
                            }
                          });
                        });
                      });
                    }
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "or",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF02B2FE)
                  )
                ),
                SizedBox(height: 15),
                Container(
                  width: 195,
                  child: RaisedButton(
                    elevation: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SvgPicture.asset(
                          "./assets/images/GoogleLogo.svg",
                          height: 20,
                        ),
                        
                        Text(
                          "Sign up with Google",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF707070)
                          ),
                        )
                      ],
                    ),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    ),
                    onPressed: (){
                      signInWithGoogle().then((user) {
                        setAuthState(user.uid).then((nothing) {
                          checkCloudFirestore(user.uid).then((cloudFirestoreState) {
                            if(cloudFirestoreState){
                              setState(() {
                                loading = false;
                              });
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage(dbRef.collection("Users").document(user.uid))));
                            } 
                            else{
                              updateUserData(user).then((nothing1) {
                                setState(() {
                                  loading = false;
                                });
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage(dbRef.collection("Users").document(user.uid))));
                              });
                            }
                          });
                        });
                      });
                    }
                  ),
                ),
                SizedBox(height: 15),
                loading ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      "Loading...",
                      style: GoogleFonts.poppins(
                        color: Color(0xFFC53AFF)
                      ),
                    )
                  ],
                ) : Container(width:0,height:0)
              ],
            ),
          )
        )
      ),
    );
  }
}