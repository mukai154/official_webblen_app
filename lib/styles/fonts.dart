import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';

class Fonts {

  Widget textW300(String text, double size, Color textColor, TextAlign alignment){
    return Text(
      text,
      style: TextStyle(fontSize: size, fontFamily: 'Barlow', fontWeight: FontWeight.w300, color: textColor),
      textAlign: alignment,
    );
  }

  Widget textW400(String text, double size, Color textColor, TextAlign alignment){
    return Text(
      text,
      style: TextStyle(fontSize: size, fontFamily: 'Barlow', fontWeight: FontWeight.w400, color: textColor),
      textAlign: alignment,
    );
  }

  Widget textW500(String text, double size, Color textColor, TextAlign alignment){
    return Text(
      text,
      style: TextStyle(fontSize: size, fontFamily: 'Barlow', fontWeight: FontWeight.w500, color: textColor),
      textAlign: alignment,
      softWrap: true,
    );
  }


  Widget textW700(String text, double size, Color textColor, TextAlign alignment){
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.1),
      textAlign: alignment,
    );
  }

  Widget textW800(String text, double size, Color textColor, TextAlign alignment){
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 0.1),
      textAlign: alignment,
    );
  }

  Widget textW900(String text, double size, Color textColor, TextAlign alignment){
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 0.1),
      textAlign: alignment,
    );
  }

  static final alertDialogHeader =  new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: FlatColors.blackPearl);

  static final alertDialogBody =  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, color: FlatColors.londonSquare);

  static final alertDialogBodySmall =  new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, color: FlatColors.londonSquare);

  static final alertDialogAction =  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: FlatColors.blackPearl);
}