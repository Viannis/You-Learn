import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youlearn/assets/themeProvider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youlearn/main.dart';
import 'package:youlearn/pages/categoryScreen.dart';
import 'package:youlearn/pages/courseContentScreen.dart';
import 'package:youlearn/pages/profileScreen.dart';
import './categoryCoursesScreen.dart';
import './enrollmentScreen.dart';

class CourseScreen extends StatefulWidget {
  final DocumentReference _documentReference;
  CourseScreen(this._documentReference);
  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool allSelected = true;
  bool enrolledSelected = false;
  Firestore dbRef = Firestore.instance;

  Future<DocumentSnapshot> checkEnrolled(DocumentReference categoryRef) async{
    DocumentSnapshot courseRef = await widget._documentReference.collection("Enrolled").getDocuments().then((value) => value.documents.firstWhere((element) => element.data["course"] == categoryRef,orElse: () => null));
    return courseRef;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: 25,
          ),
          onPressed: (){
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        centerTitle: true,
        title: Text(
          "Courses",
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.textTheme.headline1.color,
            letterSpacing: 0.8
          )
        ),
      ),
      drawer: AppDrawer(widget._documentReference),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width * 0.05),
        child: Column( 
          children: <Widget>[
            SizedBox(height:20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                allSelected ? 
                ButtonTheme(
                  minWidth: 150,
                  height: 31,
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 2
                      )
                    ),
                    onPressed: (){
                    }, 
                    child: Text(
                      "All",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.9,
                        color: Colors.white
                      )
                    )
                  ),
                ) : 
                ButtonTheme(
                  minWidth: 150,
                  height: 31,
                  child: FlatButton(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 2
                      )
                    ),
                    onPressed: (){
                      setState(() {
                        allSelected = !allSelected;
                        enrolledSelected = !enrolledSelected;
                      });
                    }, 
                    child: Text(
                      "All",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.9,
                        color: Theme.of(context).accentColor
                      ),
                    )
                  ),
                ),
                enrolledSelected ? 
                ButtonTheme(
                  minWidth: 150,
                  height: 31,
                  child: FlatButton(
                    color: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 2
                      )
                    ),
                    onPressed: (){

                    }, 
                    child: Text(
                      "Enrolled",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.9,
                        color: Colors.white
                      )
                    )
                  ),
                ) :
                ButtonTheme(
                  minWidth: 150,
                  height: 31,
                  child: FlatButton(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 2
                      )
                    ),
                    onPressed: (){
                      setState(() {
                        allSelected = !allSelected;
                        enrolledSelected = !enrolledSelected;
                      });
                    }, 
                    child: Text(
                      "Enrolled",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.9,
                        color: Theme.of(context).accentColor
                      )
                    )
                  ),
                )
              ],
            ),
            SizedBox(height:20),
            allSelected ? StreamBuilder(
              stream: widget._documentReference.collection("Categories").snapshots(),
              builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.hasData){
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: Text("Loading...")
                      );
                      break;
                    default:
                      List<DocumentSnapshot> docSnapshot = snapshot.data.documents;
                      return Container(
                        height: MediaQuery.of(context).size.height - 200,
                        child: ListView.builder(
                          itemCount: docSnapshot.length,
                          itemBuilder: (BuildContext context, int index){
                            DocumentReference docReference = docSnapshot[index]["category"];
                            double cardWidth = MediaQuery.of(context).size.width - 80;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[       
                                docSnapshot[index]["length"] > 1 ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    FlatButton(
                                      onPressed: (){},
                                      child: null
                                    ),
                                    Text(
                                      docSnapshot[index]["title"],
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.7,
                                        color: Theme.of(context).textTheme.headline3.color
                                      )
                                    ),
                                    FlatButton(
                                      onPressed: (){
                                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CategoryCoursesScreen(docReference,docSnapshot[index]["title"],widget._documentReference)));
                                      }, 
                                      child: Text(
                                        "View all",
                                        style: GoogleFonts.poppins(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.3
                                        ),
                                      )
                                    )
                                  ],
                                ) : 
                                Text(
                                  docSnapshot[index]["title"],
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 0.7,
                                    color: Theme.of(context).textTheme.headline3.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17
                                  )
                                ),
                                SizedBox(height:10),
                                FutureBuilder(
                                  future: docReference.collection("Courses").getDocuments(),
                                  builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot1){
                                    if(snapshot1.hasData){
                                      switch (snapshot1.connectionState) {
                                        case ConnectionState.waiting:
                                          return Center(
                                            child: Text("Loading...")
                                          );
                                          break;
                                        default:
                                          List<DocumentSnapshot> dcSnap = snapshot1.data.documents;
                                          return Container(
                                            height: 200,
                                            child: ListView.builder(
                                              itemCount: dcSnap.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (BuildContext context, int index){
                                                DocumentReference dcRef = dcSnap[index]["course"];
                                                return FutureBuilder(
                                                  future: dcRef.get(),
                                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot3){
                                                    if(snapshot3.hasData){
                                                      DocumentSnapshot courseData = snapshot3.data;
                                                      return Card(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(25)
                                                        ),
                                                        child: Container(
                                                          padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 14),
                                                          width: cardWidth,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text(
                                                                courseData.data["title"],
                                                                style: GoogleFonts.poppins(
                                                                  color: Colors.white,
                                                                  fontSize: 25,
                                                                  fontWeight: FontWeight.bold,
                                                                  letterSpacing: 1
                                                                )
                                                              ),
                                                              Text(
                                                                courseData.data["level"],
                                                                style: GoogleFonts.poppins(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.w400,
                                                                  fontSize: 13,
                                                                  letterSpacing: 0.5
                                                                )
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: <Widget>[
                                                                  RatingBarIndicator(
                                                                    rating: courseData.data["ratings"].toDouble(),
                                                                    itemCount: 5,
                                                                    itemSize: 17,
                                                                    physics: BouncingScrollPhysics(),
                                                                    itemBuilder: (BuildContext context,int index){
                                                                      return Icon(
                                                                        Icons.star,
                                                                        color: Colors.amber,
                                                                      );
                                                                    }
                                                                  ),
                                                                  RichText(
                                                                    textAlign: TextAlign.center,
                                                                    text: TextSpan(
                                                                      style: GoogleFonts.roboto(
                                                                        fontWeight: FontWeight.w600,
                                                                        fontSize: 15                              
                                                                      ),
                                                                      children: [
                                                                        WidgetSpan(
                                                                          child: Icon(
                                                                            Icons.person,
                                                                            color: Colors.white,
                                                                            size: 17
                                                                          )
                                                                        ),
                                                                        WidgetSpan(child: SizedBox(width:3)),
                                                                        TextSpan(
                                                                          text: courseData.data["followers"].toString()
                                                                        )
                                                                      ]
                                                                    )
                                                                  ),
                                                                  ButtonTheme(
                                                                    height: 30,                                                                  
                                                                    child: RaisedButton(
                                                                      elevation: 1,
                                                                      color: Theme.of(context).accentColor,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(30)
                                                                        ),
                                                                        onPressed: (){
                                                                          checkEnrolled(courseData.reference).then((value){
                                                                            value != null ? Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CourseContentScreen(value.reference,courseData.data["title"]))) : Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => EnrollmentScreen(dcRef,courseData.data["title"],widget._documentReference)));
                                                                          });                 
                                                                        },
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: <Widget>[
                                                                            Text(
                                                                              "Explore",
                                                                              style: GoogleFonts.roboto(
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Colors.white,
                                                                                letterSpacing: 0.6
                                                                              ),
                                                                            ),
                                                                            SizedBox(width:10),
                                                                            Icon(
                                                                              Icons.send,
                                                                              size: 13,
                                                                              color: Colors.white,
                                                                            )
                                                                          ],
                                                                        )
                                                                      ),
                                                                  )
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(25),
                                                            color: Colors.white,
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                Colors.black.withOpacity(0.71),
                                                                Colors.black.withOpacity(0.14)
                                                              ],
                                                              begin: Alignment.bottomLeft,
                                                              end: Alignment.topRight
                                                            ),
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                                                              image: NetworkImage(
                                                                courseData.data["coverImageUrl"]
                                                              )
                                                            )
                                                          ),
                                                        )
                                                      );
                                                    }
                                                    else{
                                                      return Container(
                                                        width:0,
                                                        height:0
                                                      );
                                                    }
                                                  } 
                                                );
                                              }
                                            )
                                          );
                                      }
                                    }
                                    else if(snapshot1.hasError){
                                      return Center(
                                        child: Text("Oops Error occured")
                                      );
                                    }
                                    else{
                                      return Center(
                                        child: Shimmer.fromColors(
                                          baseColor: Color(0xFFCCCCCC),
                                          highlightColor: Color(0xFFE2E2E2),
                                          child: Container(
                                            width: cardWidth,
                                            height: 180,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(25)
                                            ),
                                          ),
                                        )
                                      );
                                    }
                                  }
                                ),
                                SizedBox(height:15)
                              ],
                            );
                          }
                        ),
                      );
                  }
                }
                else if(snapshot.hasError){
                  return Center(
                    child: Text("Oops Error Occured")
                  );
                }
                else{
                  return Center(
                    child: CircularProgressIndicator()
                  );
                }
              }
            ) : FutureBuilder(
              future: widget._documentReference.collection("Enrolled").getDocuments(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.hasData){
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: Text("Loading..."),);
                      break;
                    default:
                      return snapshot.data.documents.length > 0 ? Container(
                        height: MediaQuery.of(context).size.height - 200,
                        child: ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context,int index){
                            DocumentReference docRef = snapshot.data.documents[index].data["course"];
                            return Column(
                              children: <Widget>[
                                FutureBuilder(
                                  future: docRef.get(),
                                  builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot1){
                                    if(snapshot1.hasData){
                                      DocumentSnapshot courseData = snapshot1.data;
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25)
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 14),
                                          width: MediaQuery.of(context).size.width,
                                          height: 200,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: <Widget>[
                                              snapshot.data.documents[index].data["completed"] ? 
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: Colors.white,
                                                ),
                                                width: 130,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Text(
                                                      "Completed",
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.black.withOpacity(0.7),
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                        fontSize: 13
                                                      ),
                                                    ),
                                                    SizedBox(width:10),
                                                    Icon(
                                                      Icons.check_circle,
                                                      size: 25,
                                                      color: Color(0xFF55FF00),
                                                    )
                                                  ],
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: Colors.white,
                                                ),
                                                width: 110,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Text(
                                                      "Ongoing",
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.black.withOpacity(0.7),
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                        fontSize: 13
                                                      ),
                                                    ),
                                                    SizedBox(width:10),
                                                    Icon(
                                                      Icons.remove_circle,
                                                      size: 25,
                                                      color: Theme.of(context).primaryColor,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    courseData.data["title"],
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1
                                                    )
                                                  ),
                                                  Text(
                                                    courseData.data["level"],
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 13,
                                                      letterSpacing: 0.5
                                                    )
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      RatingBarIndicator(
                                                        rating: courseData.data["ratings"].toDouble(),
                                                        itemCount: 5,
                                                        itemSize: 17,
                                                        physics: BouncingScrollPhysics(),
                                                        itemBuilder: (BuildContext context,int index){
                                                          return Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                          );
                                                        }
                                                      ),
                                                      RichText(
                                                        textAlign: TextAlign.center,
                                                        text: TextSpan(
                                                          style: GoogleFonts.roboto(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 15                              
                                                          ),
                                                          children: [
                                                            WidgetSpan(
                                                              child: Icon(
                                                                Icons.person,
                                                                color: Colors.white,
                                                                size: 17
                                                              )
                                                            ),
                                                            WidgetSpan(child: SizedBox(width:3)),
                                                            TextSpan(
                                                              text: courseData.data["followers"].toString()
                                                            )
                                                          ]
                                                        )
                                                      ),
                                                      ButtonTheme(
                                                        height: 30,                                                                  
                                                        child: RaisedButton(
                                                          elevation: 1,
                                                          color: Theme.of(context).accentColor,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(30)
                                                            ),
                                                            onPressed: (){
                                                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CourseContentScreen(snapshot.data.documents[index].reference,courseData.data["title"])));
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget>[
                                                                Text(
                                                                  "Explore",
                                                                  style: GoogleFonts.roboto(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w700,
                                                                    color: Colors.white,
                                                                    letterSpacing: 0.6
                                                                  ),
                                                                ),
                                                                SizedBox(width:10),
                                                                Icon(
                                                                  Icons.send,
                                                                  size: 13,
                                                                  color: Colors.white,
                                                                )
                                                              ],
                                                            )
                                                          ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                              
                                              
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(25),
                                            color: Colors.white,
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.black.withOpacity(0.71),
                                                Colors.black.withOpacity(0.14)
                                              ],
                                              begin: Alignment.bottomLeft,
                                              end: Alignment.topRight
                                            ),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                                              image: NetworkImage(
                                                courseData.data["coverImageUrl"]
                                              )
                                            )
                                          ),
                                        )
                                      );
                                    }
                                    else if(snapshot1.hasError){
                                      return Container(
                                        width: 0.0,
                                        height: 0
                                      );
                                    }
                                    else{
                                      return Center(
                                        child: Shimmer.fromColors(
                                          baseColor: Color(0xFFCCCCCC),
                                          highlightColor: Color(0xFFEBEBEB),                          
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 15),
                                            width: MediaQuery.of(context).size.width,
                                            height: 180,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(25)
                                            ),
                                          ),
                                        )
                                      );
                                    }
                                  }
                                ),
                                SizedBox(height:15)
                              ],
                            );
                          }
                        ),
                      ) : Container(
                        child: Center(
                          child: Text("No documents yet")
                        )
                      );
                  }
                }
                else if(snapshot.hasError){
                  return Center(
                    child: Text(
                      "Oops Error Occured"
                    )
                  );
                }
                else{
                  return Center(
                    child: CircularProgressIndicator()
                  );
                }
              }
            )
          ],
        )
      )
    );
  }
}

class AppDrawer extends StatefulWidget {
final DocumentReference documentReference;
  AppDrawer(this.documentReference);
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signOut() async{
    googleSignIn.signOut();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView( 
          children: <Widget>[
            FutureBuilder(
              future: widget.documentReference.get(),
              builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot){
                if(snapshot.hasData){
                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(snapshot.data["imageUrl"]),
                    ),
                    accountName: Text(
                      snapshot.data["name"],
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white
                      )
                    ), 
                    accountEmail: Text(
                      snapshot.data["email"],
                      style:GoogleFonts.poppins(
                        fontSize: 12,
                        letterSpacing: 0.7,
                        color: Colors.white,
                        fontWeight: FontWeight.w500
                      )
                    )
                  );
                }
                else{
                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                    ),
                    accountName: Text(
                      "User Name",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white
                      )
                    ), 
                    accountEmail: Text(
                      "useremail@gmail.com",
                      style:GoogleFonts.poppins(
                        fontSize: 12,
                        letterSpacing: 0.7,
                        color: Colors.white,
                        fontWeight: FontWeight.w500
                      )
                    )
                  );
                }
              }
            ),
            ListTile(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CategoryScreen(widget.documentReference)));
              },
              title: Text(
                "Category",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w400
                )
              ),
              leading: Icon(
                Icons.widgets,
                color: Theme.of(context).primaryColor,
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(widget.documentReference)));
              },
              title: Text(
                "Profile",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w400
                )
              ),
              leading: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              title: Text(
                "Dark Mode",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w400
                )
              ),
              leading: Icon(
                Icons.brightness_6,
                color: Theme.of(context).primaryColor,
              ),
              trailing: Checkbox(
                value: themeChange.darkTheme, 
                onChanged: (bool value){
                  themeChange.darkTheme = value;
                }
              ),
            ),
            ListTile(
              onTap: (){
                signOut().then((value){
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => MyApp()));
                });
              },
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w400
                )
              ),
              leading: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).primaryColor,
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      )
    );
  }
}