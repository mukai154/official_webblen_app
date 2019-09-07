import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:flutter/services.dart';


class AddComImage extends StatefulWidget {

  final Community com;
  AddComImage({this.com});

  @override
  State<StatefulWidget> createState() {
    return _AddComImageState();
  }
}

class _AddComImageState extends State<AddComImage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String imageURL;


  //Form Validations
  void validateAndSubmit() async {
    final form = formKey.currentState;
    form.save();
    CommunityDataService().setCommunityImageURL(widget.com.areaName, widget.com.name, imageURL).whenComplete((){
      Navigator.of(context).pop();
    });
  }


  @override
  Widget build(BuildContext context) {

    Widget _buildUrlField(){
      return Container(
        margin: EdgeInsets.only(left: 16.0, top: 4.0, right: 8.0),
        child: new TextFormField(
          initialValue: "",
          maxLines: 1,
          style: TextStyle(color: Colors.black54, fontSize: 16.0, fontFamily: 'Barlow', fontWeight: FontWeight.w500),
          autofocus: false,
          onSaved: (value) => imageURL = value,
          inputFormatters: [
            BlacklistingTextInputFormatter(RegExp("[\\ |\\,]"))
          ],
          decoration: InputDecoration(
            icon: Icon(Icons.link, color: FlatColors.darkGray, size: 18),
            border: InputBorder.none,
            hintText: "Image URL",
            counterStyle: TextStyle(fontFamily: 'Barlow'),
            contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
          ),
        ),
      );
    }

    final formView = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                _buildUrlField(),
                CustomColorButton(
                  text: "Submit",
                  textColor: FlatColors.darkGray,
                  backgroundColor: Colors.white,
                  height: 45.0,
                  width: 150.0,
                  hPadding: 16.0,
                  vPadding: 16.0,
                  onPressed: () => validateAndSubmit(),
                )
              ],
            ),
          )
      ),
    );

    return Scaffold(
        appBar: WebblenAppBar().basicAppBar("Add Com IMage"),
        body: formView
    );
  }

}