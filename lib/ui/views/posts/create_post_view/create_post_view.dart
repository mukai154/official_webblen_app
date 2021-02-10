import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/posts/create_post_view/create_post_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/text_field/multi_line_text_field.dart';

class CreatePostView extends StatelessWidget {
  final nameController = TextEditingController();
  final goalsController = TextEditingController();
  final whyController = TextEditingController();
  final whoController = TextEditingController();
  final resourcesController = TextEditingController();
  final charityWebsiteController = TextEditingController();
  final action1Controller = TextEditingController();
  final action2Controller = TextEditingController();
  final action3Controller = TextEditingController();
  final description1Controller = TextEditingController();
  final description2Controller = TextEditingController();
  final description3Controller = TextEditingController();

  Widget textFieldHeader(String header, String subHeader) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            header,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appFontColor(),
            ),
          ),
          SizedBox(height: 4),
          Text(
            subHeader,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: appFontColorAlt(),
            ),
          ),
        ],
      ),
    );
  }

  Widget imgBtn(BuildContext context, CreatePostViewModel model) {
    return GestureDetector(
      onTap: null,
      child: Container(
        height: screenHeight(context),
        width: screenHeight(context),
        child: Center(
          child: Column(
            children: [
              Icon(
                FontAwesomeIcons.camera,
                color: appFontColorAlt(),
                size: 16,
              ),
              verticalSpaceTiny,
              CustomText(
                text: '1:1',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: appFontColorAlt(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imgPreview() {
    return GestureDetector(
      onTap: null,
    );
  }

  Widget form(BuildContext context, CreatePostViewModel model) {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: [
          verticalSpaceSmall,

          ///POST IMAGE
          imgBtn(context, model),
          verticalSpaceMedium,

          ///POST BODY
          MultiLineTextField(controller: model.postTextController, hintText: "What's on Your Mind?", initialValue: null),
          verticalSpaceSmall,

          ///POST
          textFieldHeader(
            "Tags",
            "What topics are related this post?",
          ),
          verticalSpaceSmall,

          verticalSpaceLarge,
          CustomButton(
            height: 48,
            backgroundColor: appButtonColor(),
            text: "Done",
            textColor: Colors.white,
            isBusy: model.isBusy,
            onPressed: () async {
              // bool formSuccess = await model.validateAndSubmitForm(
              //   name: nameController.text.trim(),
              //   goal: goalsController.text.trim(),
              //   why: whyController.text.trim(),
              //   who: whoController.text.trim(),
              //   resources: resourcesController.text.trim(),
              //   charityURL: charityWebsiteController.text.trim(),
              //   action1: action1Controller.text.trim(),
              //   action2: action2Controller.text.trim(),
              //   action3: action3Controller.text.trim(),
              //   description1: description1Controller.text,
              //   description2: description2Controller.text,
              //   description3: description3Controller.text,
              // );
              // if (formSuccess) {
              //   model.displayCauseUploadSuccessBottomSheet();
              // }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreatePostViewModel>.reactive(
      viewModelBuilder: () => CreatePostViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(title: "New Post", showBackButton: true),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: screenHeight(context),
            width: screenWidth(context),
            color: appBackgroundColor(),
            child: form(context, model),
          ),
        ),
      ),
    );
  }
}
