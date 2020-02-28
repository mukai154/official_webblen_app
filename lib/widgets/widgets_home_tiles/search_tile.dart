import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class SearchTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 4.0,
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 246, 245, 245),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 12,
            ),
            child: Icon(
              Icons.search,
              color: Colors.black54,
              size: 18.0,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: 9,
            ),
            child: MediaQuery(
              child: TypewriterAnimatedTextKit(
                  duration: Duration(
                    seconds: 20,
                  ),
                  text: [
                    "Find Communities",
                    "Find Events",
                    "Find Things to Do",
                    "Find Friends",
                  ],
                  textStyle: TextStyle(
                    fontFamily: 'Helvetica Neue',
                    fontSize: 14.0,
                    color: Colors.black26,
                  ),
                  textAlign: TextAlign.start,
                  alignment:
                      AlignmentDirectional.topStart // or Alignment.topLeft
                  ),
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
