import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletionScreen extends StatefulWidget {
  final String title;
  CompletionScreen(this.title);
  @override
  _CompletionScreenState createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 50),
            Image.asset(
              './assets/images/Congrats.png',
              width: MediaQuery.of(context).size.width * 0.75,
            ),
            SizedBox(height: 30),
            Text(
              "Congratulations !",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                letterSpacing: 0.4
              ),
            ),
            SizedBox(height: 20),
            Text(
              "You have Sucessfully completed the course",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(
                  color: Theme.of(context).primaryColor
                )
              ),
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Container(
                width: 250,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.explore,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Explore other courses",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Theme.of(context).primaryColor
                      ),
                    )
                  ],
                ),
              )
            )
          ],
        )
      )
    );
  }
}