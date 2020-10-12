import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EnrollmentScreen extends StatefulWidget {
  final DocumentReference courseRef;
  final DocumentReference userRef;
  final String title;
  EnrollmentScreen(this.courseRef,this.title,this.userRef);
  @override
  _EnrollmentScreenState createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  bool loading = false;

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
          ),
        ),
        centerTitle: true,
      ),
      body: loading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal:35),
          child: FutureBuilder(
            future: widget.courseRef.get(),
            builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot){
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
                        SizedBox(
                          height:20
                        ),
                        Container(
                          width:MediaQuery.of(context).size.width,
                          height: 195, 
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                snapshot.data.data["coverImageUrl"],
                                
                              )
                            )
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                              color: Theme.of(context).textTheme.headline1.color,
                              letterSpacing: 1,
                            ),
                          )
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 30,vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(30)
                              ),
                              child: Text(
                                snapshot.data.data["level"].toString().toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 10,
                                  letterSpacing: 2
                                ),
                              )
                            ),
                            SizedBox(width:15),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14,vertical:1),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).textTheme.bodyText1.color
                                ),
                                borderRadius: BorderRadius.circular(30)
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Theme.of(context).textTheme.bodyText1.color,
                                  ),
                                  SizedBox(width:6),
                                  Text(
                                    snapshot.data.data["followers"].toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Theme.of(context).textTheme.bodyText1.color
                                    ),
                                  )
                                ],
                              )
                            ),
                            SizedBox(width:15),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14,vertical:1),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).textTheme.bodyText1.color
                                ),
                                borderRadius: BorderRadius.circular(30)
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Theme.of(context).textTheme.bodyText1.color,
                                  ),
                                  SizedBox(width:6),
                                  Text(
                                    snapshot.data.data["ratings"].toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Theme.of(context).textTheme.bodyText1.color
                                    ),
                                  )
                                ],
                              )
                            ),
                          ],
                        ),
                        SizedBox(height:10),
                        Container(
                          child: Text(
                            snapshot.data.data["description"],
                            style: GoogleFonts.poppins(
                              letterSpacing: 1,
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyText2.color,
                              fontWeight: FontWeight.w300
                            ),
                            textAlign: TextAlign.justify,
                          )
                        ),
                        SizedBox(height:15),
                        Container(
                          child: Text(
                            "Course Details",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              letterSpacing: 1
                            ),
                          )
                        ),
                        SizedBox(height:10),
                        Container(
                          child: FutureBuilder(
                            future: snapshot.data.reference.collection("Topics").getDocuments(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1){
                              if(snapshot1.hasData){
                                switch (snapshot1.connectionState) {
                                  case ConnectionState.waiting:
                                    return Center(
                                      child: Text(
                                        "Loading..."
                                      )
                                    );
                                    break;
                                  default:
                                    return Container(
                                      height: (snapshot1.data.documents.length * 40).toDouble(),
                                      child: ListView.builder(
                                        itemCount: snapshot1.data.documents.length,
                                        itemBuilder: (BuildContext context,int index){
                                          return FutureBuilder(
                                            future: snapshot.data.reference.collection("Topics").document((index+1).toString()).get(),
                                            builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot2){
                                              if(snapshot2.hasData){
                                                return Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: 40,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.check,
                                                        size: 20,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                      SizedBox(width:10),
                                                      Text(
                                                        snapshot2.data["title"],
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w400,
                                                          letterSpacing: 1
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                );
                                              }
                                              else{
                                                return Container(
                                                  width: 0,
                                                  height: 0
                                                );
                                              }
                                            }
                                          );
                                        }
                                      ),
                                    );
                                }
                              }
                              else{
                                return Center(
                                  child: Text(
                                    "Oops Error Loading"
                                  )
                                );
                              }
                            }
                          )
                        ),
                        SizedBox(height:15),
                        Container(
                          child: Text(
                            "External Links",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              letterSpacing: 1
                            ),
                          )
                        ),
                        SizedBox(height: 15),
                        FutureBuilder(
                          future: snapshot.data.reference.collection("ExternalLinks").getDocuments(),
                          builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot3){
                            if(snapshot3.hasData){
                              switch (snapshot3.connectionState) {
                                case ConnectionState.waiting:
                                  return Center(
                                    child: Text(
                                      "Loading..."
                                    )
                                  );
                                  break;
                                default:
                                  return Container(
                                    height: (snapshot3.data.documents.length * 31).toDouble(),
                                    child: ListView.builder(
                                      itemCount: snapshot3.data.documents.length,
                                      itemBuilder: (BuildContext context, int index1){
                                        return Container(
                                          height:31,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () async{
                                                  await canLaunch(snapshot3.data.documents[index1].data["link"]) ? 
                                                    await launch(snapshot3.data.documents[index1].data["link"]) : 
                                                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Sorry, the URL is currently inactive")));
                                                },
                                                child: Text(
                                                  snapshot3.data.documents[index1].data["link"],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Theme.of(context).primaryColor
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height:10)
                                            ],
                                          ),
                                        );
                                      }
                                    )
                                  );
                              }
                            }
                            else{
                              return Container();
                            }
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                }
              }
              else if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Oops Error Occured"
                  ),
                );
              }
              else{
                return Center(
                  child: CircularProgressIndicator()
                );
              }
            }
          )
        ),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        child: FlatButton(
          padding: EdgeInsets.all(0),
          color: Theme.of(context).accentColor,
          onPressed: () async{
            setState(() {
              loading = true;
            });
            await widget.userRef.collection("Enrolled").add({
              'completed' : false,
              'course' : widget.courseRef
            }).then((value) async{
              DocumentReference courseRef = await value.get().then((value) => value.data["course"]);
              int followers = (await courseRef.get().then((value) => value.data["followers"])).toInt();
              followers += 1;
              await courseRef.updateData({
                'followers' : followers
              }).then((value){
                Navigator.of(context).pop();
              });
            });
          },
          child: Text(
            "Enroll",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 2,
              fontSize: 18
            )
          )
        )
        
      )
    );
  }
}