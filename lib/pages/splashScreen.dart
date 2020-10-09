import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.grey[200],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        './assets/images/Authlogo.png',
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.montserrat(
                            fontSize: 37,
                            fontWeight: FontWeight.w600
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "You",
                              style: TextStyle(
                                color: Color(0xFFFF6F00),
                              )
                            ),
                            TextSpan(
                              text: "Learn",
                              style: TextStyle(
                                color: Color(0xFF425066),
                              )
                            )
                          ]
                        )
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "A new learning experience",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF707070),
                          letterSpacing: 0.5
                        ),
                      )
                    ],
                  ),
                )
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFFFF6F00)),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "Loading...",
                      style: TextStyle(
                        color: Color(0xFF425066),
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        letterSpacing: 1
                      ),
                    )
                  ],
                )
              )
            ],
          )
        ],
      )
    );
  }
}