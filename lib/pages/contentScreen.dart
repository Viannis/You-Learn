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
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.symmetric(horizontal:20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(),
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