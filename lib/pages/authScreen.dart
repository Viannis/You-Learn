import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    GoogleSignInAuthentication googleSignInAuthentication;
    try{
      final GoogleSignInAuthentication tempAuth = await googleSignInAccount.authentication;
      googleSignInAuthentication = tempAuth;
    }
    catch(e){
      Fluttertoast.showToast(
        msg: "Select a google account",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3
      );
      setState(() {
        loading = false;
      });
      return null;
    }
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
                Image.asset(
                  './assets/images/Authlogo.png',
                  width: MediaQuery.of(context).size.width * 0.35,

                ),
                SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.montserrat(
                      fontSize: 37,
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
                SizedBox(height: 40),
                Text(
                  "Welcome",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF464646)
                  )
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Signup or login to explore the courses offered",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.7,
                      wordSpacing: 2,
                      height: 2
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  width: 190,
                  child: RaisedButton(
                    elevation: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Image.asset(
                          './assets/images/GoogleIcon.png',
                          height: 18
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
                        if(user == null){
                          return;
                        }
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
                    }
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "or",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF02B2FE)
                  )
                ),
                SizedBox(height: 15),
                Container(
                  width: 190,
                  child: RaisedButton(
                    elevation: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Image.asset(
                          './assets/images/GoogleIcon.png',
                          height: 18
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
                        if(user == null){
                          return;
                        }
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
                    }
                  ),
                ),
                SizedBox(height: 30),
                loading ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F00)),
                      )
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Loading...",
                      style: GoogleFonts.poppins(
                        color: Color(0xFF425066),
                        fontSize: 18,
                        letterSpacing: 1
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