import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/posts/create_post_view/create_post_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/add_image_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/text_field/multi_line_text_field.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/ui/widgets/tags/tag_dropdown_field.dart';

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

  Widget selectedTags(CreatePostViewModel model) {
    return model.post.tags == null || model.post.tags.isEmpty
        ? Container()
        : Container(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: model.post.tags.length,
              itemBuilder: (BuildContext context, int index) {
                return RemovableTagButton(onTap: () => model.removeTagAtIndex(index), tag: model.post.tags[index]);
              },
            ),
          );
  }

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
    return ImageButton(
      onTap: () => model.selectImage(context: context),
      isOptional: true,
      height: screenWidth(context),
      width: screenWidth(context),
    );
  }

  Widget imgPreview(BuildContext context, CreatePostViewModel model) {
    return model.img == null
        ? ImagePreviewButton(
            onTap: () => model.selectImage(context: context),
            file: null,
            imgURL: model.post.imageURL,
            height: screenWidth(context),
            width: screenWidth(context),
          )
        : ImagePreviewButton(
            onTap: () => model.selectImage(context: context),
            file: model.img,
            imgURL: null,
            height: screenWidth(context),
            width: screenWidth(context),
          );
  }

  Widget form(BuildContext context, CreatePostViewModel model) {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: [
          ///POST IMAGE
          model.img == null && model.post.imageURL == null ? imgBtn(context, model) : imgPreview(context, model),
          verticalSpaceMedium,

          ///POST TAGS
          selectedTags(model),
          verticalSpaceMedium,

          ///POST FIELDS
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ///POST TAGS
                textFieldHeader(
                  "Tags",
                  "What topics are related to this post?",
                ),
                verticalSpaceSmall,
                TagDropdownField(
                  enabled: model.textFieldEnabled,
                  controller: model.tagTextController,
                  onTagSelected: (tag) => model.addTag(tag),
                ),
                verticalSpaceMedium,

                ///POST BODY
                textFieldHeader(
                  "Message",
                  "What would you like to share?",
                ),
                verticalSpaceSmall,
                MultiLineTextField(
                  enabled: model.textFieldEnabled,
                  controller: model.postTextController,
                  hintText: "Don't be shy...",
                  initialValue: null,
                ),
                verticalSpaceMedium,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget appBarLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: AppBarCircleProgressIndicator(color: appActiveColor(), size: 25),
    );
  }

  Widget doneButton(CreatePostViewModel model) {
    return Padding(
      padding: EdgeInsets.only(right: 16, top: 18),
      child: CustomTextButton(
        onTap: () => model.showNewContentConfirmationBottomSheet(),
        color: appFontColor(),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        text: 'Done',
        textAlign: TextAlign.right,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreatePostViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => CreatePostViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: model.isEditing ? 'Edit Post' : 'New Post',
          showBackButton: true,
          actionWidget: model.isBusy ? appBarLoadingIndicator() : doneButton(model),
        ),
        //CustomAppBar().a(title: "New Post", showBackButton: true),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
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
