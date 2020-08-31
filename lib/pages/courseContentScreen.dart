import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:youlearn/pages/ratingScreen.dart';
import 'contentScreen.dart';

class CourseContentScreen extends StatefulWidget {
  final DocumentReference _documentReference;
  final String title;
  CourseContentScreen(this._documentReference,this.title);
  @override
  _CourseContentScreenState createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  CollectionReference topicRef;
  bool quiz = false;

  Future<DocumentReference> test() async{
    return await widget._documentReference.get().then((value) => value.data["course"]);
  }

  Future<DocumentSnapshot> getRecentCourse() async{
    DocumentReference recentRef =  await widget._documentReference.get().then((value) => value.data["recent"]);
    return await recentRef.get();    
  }

  Future<CollectionReference> getTopicRef() async{
    DocumentReference docRef = await widget._documentReference.get().then((value) => value.data["course"]);
    return docRef.collection("Topics");
  }

  Future<int> getProgress() async{
    int percentage = await widget._documentReference.get().then((value) async{
      DocumentReference courseRef = value.data["course"];
      List<DocumentReference> pro = List.from(value.data["progress"]);
      int progressLength = pro.length;
      int topicsLength = await courseRef.collection("Topics").getDocuments().then((docs)=> docs.documents.length);
      int percent = ((progressLength / topicsLength) * 100).toInt();
      return percent;
    });
    return percentage;
  }

  Future<bool> checkGetProgress() async{
    var temp = await widget._documentReference.get().then((value) => value.data["progress"]);
    return temp == null ? false : true;
  }

  Future<QuerySnapshot> getTopics() async{
    DocumentReference courseRef = await widget._documentReference.get().then((value) => value.data["course"]);
    return await courseRef.collection("Topics").getDocuments();
  }

  void updateCompletedStatus() async{
    await widget._documentReference.updateData({
      'completed' : true
    });
  }

  @override
  void initState() {
    getTopicRef().then((value) => topicRef = value);
    checkGetProgress().then((value1){
      if(value1){
        getProgress().then((value){
          if(value == 100){
            updateCompletedStatus();
            setState(() {
              quiz = true;
            });
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.textTheme.headline1.color,
            letterSpacing: 0.8
          )
        )
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: <Widget>[
            SizedBox(height:30),
            StreamBuilder(
              stream: widget._documentReference.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap){
                if(snap.hasData){
                  switch (snap.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator()
                      );
                      break;
                    default:
                      return snap.data["progress"] != null ? FutureBuilder(
                        future: getProgress(),
                        builder: (BuildContext context, AsyncSnapshot<int> snaphot){
                          if(snaphot.hasData){
                            switch (snaphot.connectionState) {
                              case ConnectionState.waiting:
                                return Center();
                                break;
                              default:
                              return Column(
                              children: <Widget>[
                                Card(
                                  shape: RoundedRectangleBorder( 
                                    borderRadius: BorderRadius.circular(18)
                                  ),
                                  elevation: 8,
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left:8.0),
                                          child: Text(
                                            "Your Progress",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              letterSpacing: 0.2
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        LinearPercentIndicator(
                                          alignment: MainAxisAlignment.start,
                                          width: MediaQuery.of(context).size.width - 145,
                                          progressColor: Theme.of(context).accentColor,
                                          percent: snaphot.data / 100,
                                          trailing: Text(
                                            snaphot.data.toString() + "%",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        )
                                      ]
                                    ),
                                  )
                                ),
                                quiz ? Column(
                                  children: <Widget>[
                                    SizedBox(height: 20),
                                    RaisedButton(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                      ),
                                      color: Theme.of(context).accentColor,
                                      onPressed: (){
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => RatingScreen(widget._documentReference,widget.title)));
                                      },
                                      child: Container(
                                        width: 260,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              "Get your course completed",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.4,
                                                fontSize: 15
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                            )
                                          ],
                                        )
                                      )
                                    ),
                                    SizedBox(height:20),
                                  ],
                                ) : Container(width:0,height:0)
                              ],
                            );
                            }
                          }
                          else if(snaphot.hasError){
                            return Container(
                              width: 0,
                              height: 0
                            );
                          }
                          else{
                            return Center(
                              
                            );
                          }
                        }
                      ) : Center();
                  }
                }
                else{
                  return Container(
                    width: 0,
                    height: 0
                  );
                }
              },
            ),
            StreamBuilder(
              stream: widget._documentReference.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap){
                if(snap.hasData){
                  switch (snap.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        
                      );
                      break;
                    default:
                      return snap.data["recent"] != null ? FutureBuilder(
                        future: getRecentCourse(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                          if(snapshot.hasData){
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Center(
                                  child: CircularProgressIndicator()
                                );
                                break;
                              default:
                                return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Continue Learning",
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            height : 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Theme.of(context).accentColor
                                              ),
                                              borderRadius: BorderRadius.circular(50)
                                            ),
                                            child: Center(
                                              child: Text(
                                                "1",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context).accentColor
                                                ),
                                              ),
                                            )
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            snapshot.data["title"],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.play_arrow,
                                        color: Theme.of(context).primaryColor,
                                      ), 
                                      onPressed: (){
                                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ContentScreen(int.parse(snapshot.data.documentID), topicRef,widget._documentReference)));
                                      }
                                    ),
                                  ],
                                ),
                              ],
                            );
                            }
                          }
                          else if(snapshot.hasError){
                            return Container();
                          }
                          else{
                            return Center(
                              
                            );
                          }
                        },
                      ) : Center();
                  }
                }
                else if(snap.hasError){
                  return Container(
                    width: 0,
                    height: 0
                  );
                }
                else{
                  return Center(
                    child: CircularProgressIndicator()
                  );
                }
              },
            ),
            SizedBox(height:20),
            FutureBuilder(
              future: getTopics(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.hasData){
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator()
                      );
                      break;
                    default:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Topics",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2
                            ),
                          ),
                          SizedBox(height:10),
                          Container(
                            height: quiz ? MediaQuery.of(context).size.height - 480 : MediaQuery.of(context).size.height - 410,
                            child: ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (BuildContext context, int index){
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(left: 10),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              height : 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Theme.of(context).accentColor
                                                ),
                                                borderRadius: BorderRadius.circular(50)
                                              ),
                                              child: Center(
                                                child: Text(
                                                  (index + 1).toString(),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context).accentColor
                                                  ),
                                                ),
                                              )
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              snapshot.data.documents[index]["title"],
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.play_arrow,
                                          color: Theme.of(context).primaryColor,
                                        ), 
                                        onPressed: (){
                                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ContentScreen(int.parse(snapshot.data.documents[index].documentID), topicRef,widget._documentReference)));
                                        }
                                      ),
                                    ],
                                  );
                              }
                            )
                          )
                        ],
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

