import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:youlearn/pages/contentPageScreen.dart';

class ContentScreen extends StatefulWidget {
  final int index;
  final CollectionReference topicRef;
  final DocumentReference enrolledCourseRef;
  ContentScreen(this.index,this.topicRef,this.enrolledCourseRef);
  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  PageController controller;

  initState(){
    controller = PageController(initialPage: widget.index - 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: widget.topicRef.getDocuments(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.hasData){
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator()
                );
                break;
              default:
                return PageView.builder(
                  itemCount: snapshot.data.documents.length,
                  controller: controller,
                  physics: ClampingScrollPhysics(),
                  onPageChanged: (pageIndex){
                    // pageIndex == 0 ? notifyFirstPage() : pageIndex == 1 ? notifyLastPage() : notifyMiddlePage();
                  },
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context,int index){
                    DocumentReference docRef = widget.topicRef.document((index + 1).toString());
                    return SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal:10),
                              height: MediaQuery.of(context).size.height,
                              child: ContentPageScreen(docRef,widget.enrolledCourseRef)
                            ),
                          ],
                        ),
                      ),
                    );
                  }
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: <Widget>[
             Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton.extended(
                heroTag: "h1",
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7)
                ),
                backgroundColor: Theme.of(context).accentColor,
                onPressed: (){
                  controller.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                },
                icon: Transform.rotate(
                  angle: 90 * math.pi / 180,
                  child: Icon(
                    Icons.arrow_drop_down_circle,
                    color: Colors.white,
                  )
                ),
                label: Text(
                  "Prev",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5
                  ),
                ),
              )
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                heroTag: "h2",
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7)
                ),
                backgroundColor: Theme.of(context).accentColor,
                onPressed: (){
                  controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                },
                icon: Text(
                  "Next",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5
                  ),
                ),
                label: Transform.rotate(
                  angle: 270 * math.pi / 180,
                  child: Icon(
                    Icons.arrow_drop_down_circle,
                    color: Colors.white,
                  )
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}