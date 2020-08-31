import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class ContentPageScreen extends StatefulWidget {
  final DocumentReference docRef;
  final DocumentReference enrolledCourseRefrence;
  ContentPageScreen(this.docRef,this.enrolledCourseRefrence);
  @override
  _ContentPageScreenState createState() => _ContentPageScreenState();
}

class _ContentPageScreenState extends State<ContentPageScreen> {

  @override
  void initState() {
    updateRecent(widget.docRef);
    super.initState();
  }

  updateRecent(DocumentReference currentTopic) async{
    await widget.enrolledCourseRefrence.get().then((value) => value.data["progress"]) == null ? updateProgressNew(currentTopic) : updateProgress(currentTopic);
    await widget.enrolledCourseRefrence.updateData({
      'recent' : currentTopic,
    });
  }

  updateProgressNew(DocumentReference currentTopic) async{
    List<DocumentReference> pro = List();
    pro.add(currentTopic);
    await widget.enrolledCourseRefrence.updateData({
      'progress' : pro,
    });
  }

  updateProgress(DocumentReference currentTopic) async{   
    List<DocumentReference> pro = List<DocumentReference>.from(await widget.enrolledCourseRefrence.get().then((value) => value.data["progress"]));
    pro.contains(currentTopic) ? print("true") : updateProgressAdd(currentTopic, pro);
  }

  updateProgressAdd(DocumentReference currentTopic,List<DocumentReference> pro) async{
    pro.add(currentTopic);
    await widget.enrolledCourseRefrence.updateData({
      'progress' : pro,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.arrow_back
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FutureBuilder(
              future: widget.docRef.get(),
              builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot1){
                if(snapshot1.hasData){
                  return Text(
                    snapshot1.data["title"],
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.textTheme.headline1.color,
                      letterSpacing: 0.8
                    )
                  );
                }
                else{
                  return Text(
                    "Title",
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).appBarTheme.textTheme.headline1.color,
                      letterSpacing: 0.8
                    )
                  );
                }
              }
            ),
            Container(width: 45,)
          ],
        ),
        SizedBox(height: 30),
        FutureBuilder(
          future: widget.docRef.collection("Contents").getDocuments(),
          builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot2){
            if(snapshot2.hasData) {                                   
              switch (snapshot2.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator()
                  );
                  break;
                default:
                  return SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal:15),
                      height: MediaQuery.of(context).size.height - 200,
                      child: ListView.builder(
                        itemCount: snapshot2.data.documents.length,
                        itemBuilder: (BuildContext context, int index1){
                          return FutureBuilder(
                            future: widget.docRef.collection("Contents").document((index1 + 1).toString()).get(),
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot3){
                              if(snapshot3.hasData){
                                switch (snapshot3.data["type"]) {
                                  case "Text":
                                    return Column(
                                      children: <Widget>[
                                        Text(
                                          "\t\t\t\t\t\t\t\t\t\t\t\t\t\t" + snapshot3.data["content"],
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400
                                          ),
                                          textAlign: TextAlign.justify,
                                        ),
                                        SizedBox(
                                          height: 20
                                        )
                                      ],
                                    );
                                    break;
                                  case "Image":
                                    return Column(
                                      children: <Widget>[
                                        Image.network(snapshot3.data["content"]),
                                        SizedBox(
                                          height: 20
                                        )
                                      ],
                                    );
                                    break;
                                  case "Link":
                                    return Column(
                                      children: <Widget>[
                                        Text("Link"),
                                      ],
                                    );
                                    break;
                                  case "Button":
                                    return Column(
                                      children: <Widget>[
                                        Text("Button"),
                                      ],
                                    );
                                    break;
                                  default:
                                    return Column(
                                      children: <Widget>[
                                        Text("Default"),
                                      ],
                                    );
                                }
                              }
                              else if(snapshot3.hasError){
                                return Container(width:0,height:0);
                              }
                              else{
                                return Shimmer.fromColors(
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                            height: 18,
                                            width: 280,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              color: Theme.of(context).accentColor
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        height: 18,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: Theme.of(context).accentColor
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        height: 18,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: Theme.of(context).accentColor
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        height: 18,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: Theme.of(context).accentColor
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        height: 18,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: Theme.of(context).accentColor
                                        ),
                                      ),
                                      SizedBox(height: 25),
                                    ],
                                  ), 
                                  baseColor: Color(0xFFCCCCCC), 
                                  highlightColor: Color(0xFFE2E2E2)
                                );
                              }
                            }
                          );
                        }
                      )
                    ),
                  );
              }
            }
            else if(snapshot2.hasError){
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
    );
  }
}