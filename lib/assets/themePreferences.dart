import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DarkThemePreference {
  static const THEME_STATUS = "THEMESTATUS";
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore dbRef = FirebaseFirestore.instance;
  

  setDarkTheme(bool value) async{
    User user = _auth.currentUser;
    if(user != null){
      DocumentReference documentReference = dbRef.collection("Users").doc(user.uid);
      await documentReference.update({
        "darkTheme" : value
      });
    }
  }

  Future<bool> getTheme() async {
    User user = _auth.currentUser;
    if(user != null){
      DocumentReference documentReference = dbRef.collection("Users").doc(user.uid);
      bool darkTheme = await documentReference.get().then((value) => value.data()["darkTheme"]);
      return darkTheme ?? false;
    } else {
      return false;
    }
  }
}