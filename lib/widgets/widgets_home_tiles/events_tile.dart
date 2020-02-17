import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';

class EventsTile extends StatelessWidget {
  final VoidCallback onTap;

  EventsTile({
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.18,
        width: MediaQuery.of(context).size.width - 32.0,
        //margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/events.png"),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(),
            Container(
              width: MediaQuery.of(context).size.width - 16,
              padding: EdgeInsets.only(
                bottom: 12.0,
                left: 8.0,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MediaQuery(
                      child: Fonts().textW700(
                        'Events',
                        24.0,
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
            ),
          ],
        ),
      ),
    );
  }
}
