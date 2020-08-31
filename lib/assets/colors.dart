import 'dart:ui';
import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context){
    return isDarkTheme ? ThemeData(
      scaffoldBackgroundColor: Color(0xFF1B1B1B),
      textTheme: TextTheme(
        headline1: TextStyle(
          color: Colors.white.withOpacity(0.90)
        ),
        caption: TextStyle(
          color: Color(0xFF007CB1)
        ),
        headline2: TextStyle(
          color: Color(0xFF3B3B3B)
        ),
        headline3: TextStyle(
          color: Colors.white.withOpacity(0.9)
        ),
        bodyText1: TextStyle(
          color: Colors.white70
        ),
        bodyText2: TextStyle(
          color: Colors.white.withOpacity(0.87)
        )
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF5E5E5E)
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.87)
        ),
        color: Color(0xFF1B1B1B),
        textTheme: TextTheme(
          headline1: TextStyle(
            color: Colors.white.withOpacity(0.87)
          )
        )
      ),
      cardColor: Color(0xFF424242),
      primaryColor: Color(0xFF03CBFF),
      accentColor: Color(0xFF02B2FE),
      buttonColor: Color(0xFF2E2E2E)
      
    ) : ThemeData(
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        headline1: TextStyle(
          color: Color(0xFF676767)
        ),
        caption: TextStyle(
          color: Color(0xFF007CB1)
        ),
        headline2: TextStyle(
          color: Color(0xFF3B3B3B)
        ),
        headline3: TextStyle(
          color: Colors.black87
        ),
        bodyText1: TextStyle(
          color: Color(0xFF6D6D6D)
        ),
        bodyText2: TextStyle(
          color: Colors.black
        )
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF5E5E5E)
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          color: Colors.black.withOpacity(0.67)
        ),
        color: Colors.white,
        textTheme: TextTheme(
          headline1: TextStyle(
            color: Colors.black.withOpacity(0.67)
          )
        )
      ),
      cardColor: Colors.white,
      primaryColor: Color(0xFF2699FB),
      accentColor: Color(0xFF02B2FE),
      buttonColor: Color(0xFFB4B4B4)
    );
  }
}