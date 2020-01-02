import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';

class CustomColorButton extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final double textSize;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double hPadding;
  final double vPadding;

  CustomColorButton({this.text, this.textSize, this.height, this.width, this.onPressed, this.backgroundColor, this.textColor, this.hPadding, this.vPadding});
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: vPadding == null ? 8.0 : vPadding, horizontal: hPadding == null ? 16.0 : hPadding),
      child: Material(
        elevation: 2.0,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(25.0),
          onTap: onPressed,
          child: Container(
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: FittedBox(
                        child: Fonts().textW600(text, textSize != null ? textSize : 16.0, textColor, TextAlign.center),
                        fit: BoxFit.scaleDown,
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomColorIconButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final double height;
  final double width;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  CustomColorIconButton({this.icon, this.text, this.height, this.width, this.onPressed, this.backgroundColor, this.textColor});
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Material(
        elevation: 2.0,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(25.0),
          onTap: onPressed,
          child: Container(
            height: height,
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                icon,
                text != null ? SizedBox(width: 8.0) : Container(),
                text != null
                    ? Padding(
                        padding: EdgeInsets.all(8.0),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          child: Fonts().textW500(text, 16.0, textColor, TextAlign.center),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewEventFormButton extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  NewEventFormButton(this.label, this.labelColor, this.backgroundColor, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Material(
        elevation: 5.0,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25.0),
        child: InkWell(
          onTap: () {
            onTap();
          },
          child: Container(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: Text(label, style: TextStyle(color: labelColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlatBackButton extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  FlatBackButton(this.label, this.labelColor, this.backgroundColor, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: FlatButton(
        onPressed: () {
          onTap();
        },
        color: Colors.transparent,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Text(label, style: TextStyle(color: labelColor, fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }
}

class PlusCircleButton extends StatelessWidget {
  final Color buttonColor;
  final double size;
  final VoidCallback buttonAction;

  PlusCircleButton({this.buttonColor, this.size, this.buttonAction});

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(Icons.add_circle_outline, color: buttonColor, size: size), onPressed: buttonAction);
  }
}
