import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class FeedbackPage extends StatefulWidget {
  final WebblenUser currentUser;

  FeedbackPage({this.currentUser});

  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool submittedFeedback = false;
  String feedback;
  GlobalKey feedbackForm = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  CollectionReference feedbackRef = Firestore().collection("feedback");

  submitFeedback() async {
    ShowAlertDialogService().showLoadingDialog(context);
    FormState formState = feedbackForm.currentState;
    formState.save();
    if (feedback != null && feedback.isNotEmpty) {
      String error;
      await feedbackRef.document().setData({
        "uid": widget.currentUser.uid,
        "datePostedInMilliseconds": DateTime.now().millisecondsSinceEpoch,
        "feedback": feedback,
      }).catchError((e) {
        error = e.message;
      });
      if (error == null) {
        Navigator.of(context).pop();
        textEditingController.clear();
        ShowAlertDialogService().showSuccessDialog(context, "Thanks!", "Your Feedback Has Been Submitted");
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "Error", error);
      }
    } else {
      Navigator.of(context).pop();
      ShowAlertDialogService().showFailureDialog(context, "Error", "Feedback Cannot Be Empty");
    }
  }

  Widget feedbackField() {
    return Form(
      key: feedbackForm,
      child: TextFieldContainer(
        height: 300,
        child: TextFormField(
          controller: textEditingController,
          cursorColor: Colors.black,
          validator: (val) => val.isEmpty ? 'Field Cannot be Empty' : null,
          maxLines: null,
          onSaved: (val) {
            feedback = val.trim();
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: "What's On Your Mind?",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        "Feedback",
        GestureDetector(
          onTap: () => submitFeedback(),
          child: Container(
            margin: EdgeInsets.only(right: 16.0, top: 16.0),
            child: CustomText(
              context: context,
              text: "Submit",
              textColor: Colors.blueAccent,
              textAlign: TextAlign.left,
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 16.0,
              ),
              Fonts().textW700(
                'Have Any Ideas for Improvements or Want to Report a Bug?',
                18,
                Colors.black,
                TextAlign.left,
              ),
              SizedBox(
                height: 4.0,
              ),
              Fonts().textW400(
                "Let Us Know Your Thoughts Below!",
                14,
                Colors.black87,
                TextAlign.left,
              ),
              SizedBox(height: 16.0),
              feedbackField(),
            ],
          ),
        ),
      ),
    );
  }
}
