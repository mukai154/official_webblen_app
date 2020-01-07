import 'package:flutter/material.dart';

import 'package:webblen/styles/fonts.dart';

class MyCommunitiesTile extends StatelessWidget {
  final VoidCallback onTap;

  MyCommunitiesTile({
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.16,
        width: (MediaQuery.of(context).size.width - 16) / 2 - 14.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/community_background.png"),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MediaQuery(
                    child: Fonts().textW700(
                      'My Communities',
                      16.0,
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
