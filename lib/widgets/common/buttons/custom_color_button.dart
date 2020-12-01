import 'package:flutter/material.dart';

class CustomColorButton extends StatelessWidget {
  final String text;
  final double height;
  final double width;
  final double textSize;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;

  CustomColorButton({
    this.text,
    this.textSize,
    this.height,
    this.width,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation == null ? 2.0 : elevation,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
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
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: FittedBox(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: textSize != null ? textSize : 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ],
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
  final double elevation;

  CustomColorIconButton({
    this.icon,
    this.text,
    this.height,
    this.width,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: Material(
        elevation: elevation == null ? 2.0 : elevation,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: onPressed,
          child: Container(
            height: height,
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                icon,
                text != null
                    ? SizedBox(
                        width: 8.0,
                      )
                    : Container(),
                text != null
                    ? Padding(
                        padding: EdgeInsets.all(8.0),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaleFactor: 1.0,
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
