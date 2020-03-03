import 'package:flutter/material.dart';
import 'package:webblen/styles/custom_text.dart';

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
            child: CustomText(
              context: context,
              text: 'Search',
              textColor: Colors.black26,
              fontSize: 18.0,
              fontWeight: FontWeight.w300,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
