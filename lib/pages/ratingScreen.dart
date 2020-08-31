import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:youlearn/pages/completionScreen.dart';

class RatingScreen extends StatefulWidget {
  final DocumentReference enrolledCourseRef;
  final String title;
  RatingScreen(this.enrolledCourseRef,this.title);
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  bool ratingSubmitted = false;
  Firestore dBref = Firestore.instance;
  double tempRating = 4;
  bool loading = false;

  updateRatings() async{
    await widget.enrolledCourseRef.get().then((value) async{
      if(value.data["rating"] != null){
        double preRating = await widget.enrolledCourseRef.get().then((value) => value.data["rating"]);
        await widget.enrolledCourseRef.updateData({
          'rating' : tempRating
        }).then((nothing) async{
          DocumentReference courseRef = await widget.enrolledCourseRef.get().then((value) => value.data["course"]);
          double totalRatings = (await courseRef.get().then((value) => value.data["totalRatings"])).toDouble();
          double followers = (await courseRef.get().then((value) => value.data["followers"])).toDouble();
          totalRatings -= preRating;
          totalRatings += tempRating;
          await courseRef.updateData({
            'totalRatings' : totalRatings,
            'ratings' : double.parse((totalRatings / followers).toStringAsFixed(2))
          }).then((value){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => CompletionScreen(widget.title)));
          });
        });
      } else{
        await widget.enrolledCourseRef.updateData({
          'rating' : tempRating
        }).then((nothing) async{
          DocumentReference courseRef = await widget.enrolledCourseRef.get().then((value) => value.data["course"]);
          double totalRatings = (await courseRef.get().then((value) => value.data["totalRatings"])).toDouble();
          double followers = (await courseRef.get().then((value) => value.data["followers"])).toDouble();
          totalRatings += tempRating;
          await courseRef.updateData({
            'totalRatings' : totalRatings,
            'ratings' : double.parse((totalRatings / followers).toStringAsFixed(2))
          }).then((value){
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => CompletionScreen(widget.title)));
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: loading ? Center(child: CircularProgressIndicator()) : Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 150),
              Center(
                child: Text(
                  "Ratings...",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1
                  ),
                ),
              ),
              SizedBox(height:30),
              RatingBar(
                initialRating: 4,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  tempRating = rating;
                  setState(() {
                    ratingSubmitted = true;
                  });
                },
              ),
              SizedBox(height:30),
              Center(
                child: Text(
                  "Your ratings will be helpful in providing better courses",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ratingSubmitted ? Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        child: FlatButton(
          padding: EdgeInsets.all(0),
          color: Theme.of(context).accentColor,
          onPressed: (){
            setState(() {
              loading = true;
            });
            updateRatings();
          },
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
          )
        )
        
      ) : Container(
        color: Theme.of(context).buttonColor,
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        child: FlatButton(
          padding: EdgeInsets.all(0),
          color: Theme.of(context).buttonColor,
          onPressed: (){
            
          },
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
          )
        )
        
      ),
    );
  }
}