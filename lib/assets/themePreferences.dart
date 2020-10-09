import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DarkThemePreference {
  static const THEME_STATUS = "THEMESTATUS";
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore dbRef = Firestore.instance;
  

  setDarkTheme(bool value) async{
    FirebaseUser user = await _auth.currentUser();
    DocumentReference documentReference = dbRef.collection("Users").document(user.uid);
    await documentReference.updateData({
      "darkTheme" : value
    });
  }

  Future<bool> getTheme() async {
    FirebaseUser user = await _auth.currentUser();
    DocumentReference documentReference = dbRef.collection("Users").document(user.uid);
    bool darkTheme = await documentReference.get().then((value) => value.data["darkTheme"]);
    return darkTheme ?? false;
  }
}