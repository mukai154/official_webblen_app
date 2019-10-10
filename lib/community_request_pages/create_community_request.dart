import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/firebase_data/community_request_data.dart';
import 'package:webblen/models/community_request.dart';
import 'package:flutter/services.dart';

class CreateCommunityRequestPage extends StatefulWidget {

  final WebblenUser currentUser;
  final String areaName;
  CreateCommunityRequestPage({this.currentUser, this.areaName});

  @override
  _CreateCommunityRequestPageState createState() => _CreateCommunityRequestPageState();
}

class _CreateCommunityRequestPageState extends State<CreateCommunityRequestPage> {

  //Firebase
  CommunityRequest newRequest = CommunityRequest(status: 'pending', upVotes: [], downVotes: []);
  int reqTypeRadioVal = 0;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final requestFormKey = new GlobalKey<FormState>();

  //Form Validations
  void validateForm() async{
    ScaffoldState scaffold = scaffoldKey.currentState;
    final form = requestFormKey.currentState;
    form.save();
    if (newRequest.requestTitle.isEmpty) {
      scaffold.showSnackBar(new SnackBar(
        content: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Text("Title Cannot be Empty"),
        ),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
    } else if (newRequest.requestExplanation.isEmpty){
      scaffold.showSnackBar(new SnackBar(
        content: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Text("Please Explain the Request"),
        ),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
    } else {
      newRequest.uid = widget.currentUser.uid;
      newRequest.areaName = widget.areaName;
      newRequest.requestType = getRadioValue();
      newRequest.datePostedInMilliseconds = DateTime.now().millisecondsSinceEpoch;
      uploadRequest(newRequest);
    }
  }

  void handleRadioValueChanged(int value) {
    setState(() {
      reqTypeRadioVal = value;
    });
  }

  String getRadioValue(){
    String val = widget.areaName;
    if (reqTypeRadioVal == 1){
      val = 'app';
    }
    return val;
  }

  uploadRequest(CommunityRequest request) async {
    ShowAlertDialogService().showLoadingDialog(context);
    await CommunityRequestDataService().postRequest(request).then((error){
      if (error.isEmpty){
        //RequestCommentDataService().startChat(request.requestID);
        Navigator.of(context).pop();
        HapticFeedback.mediumImpact();
        ShowAlertDialogService().showActionSuccessDialog(context, 'Request Pending', 'Your Request is now Pending Review', (){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, 'Uh Oh!', 'There was an issue uploading your post. Please try again.');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.currentUser.uid);
  }

  @override
  Widget build(BuildContext context) {

    Widget _buildTitleField(){
      return Container(
        margin: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        decoration: BoxDecoration(
          color: FlatColors.textFieldGray,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Suggetion Title",
              contentPadding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
              border: InputBorder.none,
            ),
            onSaved: (value) => newRequest.requestTitle = value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: "Helvetica Neue",
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            textInputAction: TextInputAction.done,
            autocorrect: false,
          ),
        ),
      );
    }

    Widget _buildContent(){
      return Container(
        height: 200,
        margin: EdgeInsets.only(left: 8, right: 8, bottom: 16),
        padding: EdgeInsets.only(bottom: 8.0),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 16
        ),
        decoration: BoxDecoration(
          color: FlatColors.textFieldGray,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child:  MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: TextFormField(
            maxLines: 10,
            maxLength: 500,
            maxLengthEnforced: true,
            decoration: InputDecoration(
              hintText: "Please Explain this Suggestion...",
              contentPadding: EdgeInsets.all(8),
              border: InputBorder.none,
            ),
            onSaved: (value) => newRequest.requestExplanation = value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: "Helvetica Neue",
            ),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.multiline,
            autocorrect: true,
          ),
        ),
      );
    }

    Widget _buildRadioButtons() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CustomColorButton(
                      height: 30.0,
                      width: 125.0,
                      text: widget.areaName,
                      textColor: reqTypeRadioVal == 0 ? Colors.white : Colors.black,
                      backgroundColor: reqTypeRadioVal == 0 ? FlatColors.webblenRed : FlatColors.textFieldGray,
                      onPressed: () {
                        reqTypeRadioVal = 0;
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 8.0),
                    CustomColorButton(
                      height: 30.0,
                      width: 125.0,
                      text: 'Webblen',
                      textColor: reqTypeRadioVal == 1 ? Colors.white : Colors.black,
                      backgroundColor: reqTypeRadioVal == 1 ? FlatColors.webblenRed : FlatColors.textFieldGray,
                      onPressed: () {
                        reqTypeRadioVal = 1;
                        setState(() {});
                      },
                    ),
                  ]
              ),
            ]
        ),
      );
    }


    return Scaffold(
      key: scaffoldKey,
      appBar: WebblenAppBar().actionAppBar(
          'New Suggestion',
        GestureDetector(
          onTap: () => validateForm(),
          child: Padding(
            padding: EdgeInsets.only(top: 20.0, right: 16.0),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: Fonts().textW500('Submit', 16.0, Colors.grey, TextAlign.right),
            ),
          ),
        )
      ),
      body: Container(
        color: Colors.white,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Form(
              key: requestFormKey,
              child: ListView(
                children: <Widget>[
                  _buildTitleField(),
                  SizedBox(height: 8.0),
                  _buildContent(),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
                    child:  MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: Fonts().textW700("This Suggestion is For:", 18.0, FlatColors.darkGray, TextAlign.left),
                    ),
                  ),
                  _buildRadioButtons(),
                ],
              )
          ),
        ),
      ),
    );
  }
}




