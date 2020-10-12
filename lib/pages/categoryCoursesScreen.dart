import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youlearn/pages/courseContentScreen.dart';
import 'package:youlearn/pages/enrollmentScreen.dart';

class CategoryCoursesScreen extends StatefulWidget {
  final DocumentReference docReference;
  final DocumentReference userRef;
  final String title;
  CategoryCoursesScreen(this.docReference, this.title, this.userRef);
  @override
  _CategoryCoursesScreenState createState() => _CategoryCoursesScreenState();
}

class _CategoryCoursesScreenState extends State<CategoryCoursesScreen> {
  
  Future<DocumentSnapshot> checkEnrolled(DocumentReference categoryRef) async{
    DocumentSnapshot courseRef = await widget.userRef.collection("Enrolled").getDocuments().then((value) => value.documents.firstWhere((element) => element.data["course"] == categoryRef,orElse: () => null));
    return courseRef;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.textTheme.headline1.color,
            letterSpacing: 0.8
          )
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal:20),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            FutureBuilder(
              future: widget.docReference.collection("Courses").getDocuments(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.hasData){
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator()
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Loading...",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w400
                                ),
                              ),
                            ],
                          )
                        )
                      );
                      break;
                    default:
                     return Container(
                       height: MediaQuery.of(context).size.height - 130,
                       child: ListView.builder(
                         itemCount: snapshot.data.documents.length,
                         itemBuilder: (BuildContext context, int index){
                           DocumentReference docRef = snapshot.data.documents[index]["course"];
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
                                                          value != null ? Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => CourseContentScreen(value.reference,courseData.data["title"]))) : Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => EnrollmentScreen(docRef,courseData.data["title"],widget.docReference)));
                                                        }); 
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
                                      width:0,
                                      height:0
                                     );
                                   }
                                   else{
                                     return Center(
                                        child: Shimmer.fromColors(
                                            baseColor: Color(0xFFCCCCCC),
                                            highlightColor: Color(0xFFE2E2E2),                          child: Container(
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
                                 },
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
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(),
                        Image.asset(
                          './assets/images/Error.png',
                          width: MediaQuery.of(context).size.width * 0.6
                        ),
                        SizedBox(),
                        Text(
                          "Oops!",
                          style: GoogleFonts.poppins(
                            fontSize: 35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Some error occurred, Check your Internet and try again later',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,
                            color: Theme.of(context).primaryColor
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(),
                      ],
                    ),
                  );
                }
                else{
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator()
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Loading...",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w400
                            ),
                          ),
                        ],
                      )
                    )
                  );
                }
              }
            ),
          ],
        )
      )
    );
  }
}