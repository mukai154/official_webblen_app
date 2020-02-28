import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';

class CommunityRequestTile extends StatelessWidget {
  final VoidCallback onTap;

  CommunityRequestTile({
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 4.0,
        ),
        height: MediaQuery.of(context).size.height * 0.18,
        width: (MediaQuery.of(context).size.width - 16) / 2 - 14.0,
        //margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/idea.png"),
            fit: BoxFit.cover,
          ),
          boxShadow: ([
            BoxShadow(
              color: Colors.black12,
              blurRadius: 1.8,
              spreadRadius: 0.6,
              offset: Offset(0.0, 2.5),
            ),
          ]),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width / 2 - 16,
              padding: EdgeInsets.only(
                top: 12.0,
                left: 8.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MediaQuery(
                    child: Fonts().textW700(
                      'Have an Idea?',
                      14.0,
                      Colors.black,
                      TextAlign.left,
                    ),
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
