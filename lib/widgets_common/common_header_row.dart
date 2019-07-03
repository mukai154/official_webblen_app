import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';

class HeaderRow extends StatelessWidget {

  final double verticalPadding;
  final double horizontalPadding;
  final String headerText;

  HeaderRow(this.verticalPadding, this.horizontalPadding, this.headerText);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
          child: new Text(headerText, style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w600)),
        )
      ],
    );
  }
}

class HeaderRowCentered extends StatelessWidget {

  final double verticalPadding;
  final double horizontalPadding;
  final String headerText;

  HeaderRowCentered(this.verticalPadding, this.horizontalPadding, this.headerText);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
          child: new Text(headerText, style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w600)),
        )
      ],
    );
  }
}


class DarkHeaderRow extends StatelessWidget {

  final double verticalPadding;
  final double horizontalPadding;
  final String headerText;

  DarkHeaderRow(this.verticalPadding, this.horizontalPadding, this.headerText);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
          child: new Text(headerText, style: TextStyle(color: FlatColors.darkGray, fontSize: 24.0, fontWeight: FontWeight.w600)),
        )
      ],
    );
  }
}

class DarkHeaderRowWithAction extends StatelessWidget {

  final double verticalPadding;
  final double horizontalPadding;
  final String headerText;
  final VoidCallback callback;

  DarkHeaderRowWithAction(this.verticalPadding, this.horizontalPadding, this.headerText, this.callback);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
          child: new Text(headerText, style: TextStyle(color: FlatColors.darkGray, fontSize: 24.0, fontWeight: FontWeight.w600)),
        ),
        new Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
            child: FlatButton(onPressed: callback, child: Text("Finish", style: TextStyle(fontWeight: FontWeight.w600),))
        ),
      ],
    );
  }
}