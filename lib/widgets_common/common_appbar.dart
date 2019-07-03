import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/services_general/services_show_alert.dart';

class WebblenAppBar {

  Widget basicAppBar(String appBarTitle){
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700(appBarTitle, 20.0, Colors.black, TextAlign.center),
      leading: BackButton(color: Colors.black),
    );
  }

  Widget homeAppBar(Widget leadingWidget, Widget logo, Widget trailingWidget){
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: logo,
      leading: leadingWidget,
      actions: <Widget>[
        trailingWidget
      ],
    );
  }

  Widget pagingAppBar(BuildContext context, String appBarTitle, String nextButtonTitle, VoidCallback prevPage, VoidCallback nextPage){
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700(appBarTitle, 20.0, FlatColors.darkGray, TextAlign.center),
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.arrowLeft, color: FlatColors.darkGray, size:  16.0),
        onPressed: prevPage,
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16.0, right: 16.0),
          child: GestureDetector(
            onTap: nextPage,
            child: Fonts().textW500(nextButtonTitle, 18.0, FlatColors.darkGray, TextAlign.right),
          ),
        ),
      ],
    );
  }

  Widget newEventAppBar(BuildContext context, String appBarTitle, String cancelHeader, VoidCallback cancelAction){
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700(appBarTitle, 20.0, FlatColors.darkGray, TextAlign.center),
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.times, color: FlatColors.darkGray, size:  16.0),
        onPressed: (){
          ShowAlertDialogService().showCancelDialog(context, cancelHeader, cancelAction);
        },
      ),
    );
  }

  Widget actionAppBar(String appBarTitle, Widget actionWidget){
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700(appBarTitle, 20.0, FlatColors.darkGray, TextAlign.center),
      leading: BackButton(color: FlatColors.darkGray),
      actions: <Widget>[
        actionWidget
      ],
    );
  }
  // ** APP BAR
}

class FABBottomAppBarItem {
  IconData iconData;
  String text;
  FABBottomAppBarItem({this.iconData, this.text});
}

class FABBottomAppBar extends StatefulWidget {

  final List<FABBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;

  FABBottomAppBar({
    this.items,
    this.centerItemText,
    this.height: 65.0,
    this.iconSize: 24.0,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.notchedShape,
    this.onTabSelected,
  }) {
    assert(this.items.length == 2 || this.items.length == 4);
  }


  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 0;

  _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTabItem({FABBottomAppBarItem item, int index, ValueChanged<int> onPressed}){
    Color color = _selectedIndex == index ? FlatColors.webblenRed : FlatColors.lightAmericanGray;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.iconData, color: color, size: widget.iconSize),
                SizedBox(height: 4),
                Fonts().textW300(
                    item.text,
                    12.0,
                    widget.color,
                    TextAlign.center
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: widget.iconSize + 8),
            Fonts().textW500(
                widget.centerItemText ?? '',
                16.0,
                widget.color,
                TextAlign.center
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });

    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      color: widget.backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items,
      ),
    );
  }
}