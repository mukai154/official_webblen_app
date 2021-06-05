import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/posts/create_post_view/create_post_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/add_image_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/text_field/auto_complete_address_text_field/auto_complete_address_text_field.dart';
import 'package:webblen/ui/widgets/common/text_field/multi_line_text_field.dart';
import 'package:webblen/ui/widgets/tags/tag_auto_complete.field.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';

class CreatePostView extends StatelessWidget {
  final String? id;
  CreatePostView(@PathParam() this.id);

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
      onModelReady: (model) => model.initialize(id!),
      viewModelBuilder: () => CreatePostViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: model.isEditing ? 'Edit Post' : 'New Post',
          showBackButton: true,
          onPressedBack: () => model.navigateBack(),
          actionWidget: model.isBusy ? appBarLoadingIndicator() : doneButton(model),
        ),
        //CustomAppBar().a(title: "New Post", showBackButton: true),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: screenHeight(context),
            width: screenWidth(context),
            color: appBackgroundColor(),
            child: Container(
              child: model.initializing
                  ? Container()
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        ///IMAGE
                        model.contentImageFile == null && model.post.imageURL == null
                            ? _ImageButton(
                                selectImage: () => model.selectImage(),
                              )
                            : _ImagePreview(
                                selectImage: () => model.selectImage(),
                                imgFile: model.contentImageFile,
                                imageURL: model.post.imageURL,
                              ),
                        verticalSpaceMedium,

                        ///TAGS
                        _SelectedTags(
                          tags: model.post.tags,
                          removeTagAtIndex: (index) => model.removeTagAtIndex(index),
                        ),
                        verticalSpaceMedium,

                        ///POST FIELDS
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ///TAG AUTOCOMPLETE
                              _TextFieldHeader(
                                header: "Tags",
                                subHeader: "What topics are related to this post?",
                                required: true,
                              ),
                              verticalSpaceSmall,
                              TagAutoCompleteField(
                                enabled: model.textFieldEnabled,
                                controller: model.tagTextController,
                                onTagSelected: (tag) => model.addTag(tag!),
                              ),
                              verticalSpaceMedium,

                              ///DESCRIPTION
                              _TextFieldHeader(
                                header: "Message",
                                subHeader: "What would you like to share?",
                                required: true,
                              ),
                              verticalSpaceSmall,
                              _PostMessageField(),
                              verticalSpaceMedium,

                              ///Location
                              _TextFieldHeader(
                                header: "Location",
                                subHeader: "Which city would you like to show this post to?",
                                required: true,
                              ),
                              verticalSpaceSmall,
                              _PostAddressAutoComplete(),
                              verticalSpaceMedium,
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextFieldHeader extends StatelessWidget {
  final String header;
  final String subHeader;
  final bool required;
  _TextFieldHeader({required this.header, required this.subHeader, required this.required});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                header,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
              ),
              required
                  ? Text(
                      " *",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.webblenRed,
                      ),
                    )
                  : Container(),
            ],
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
}

class _ImageButton extends StatelessWidget {
  final VoidCallback selectImage;
  _ImageButton({required this.selectImage});

  @override
  Widget build(BuildContext context) {
    return ImageButton(
      onTap: selectImage,
      isOptional: true,
      height: screenWidth(context),
      width: screenWidth(context),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final VoidCallback selectImage;
  final File? imgFile;
  final String? imageURL;
  _ImagePreview({required this.selectImage, this.imgFile, this.imageURL});

  @override
  Widget build(BuildContext context) {
    return imgFile == null
        ? ImagePreviewButton(
            onTap: selectImage,
            file: null,
            imgURL: imageURL,
            height: screenWidth(context),
            width: screenWidth(context),
          )
        : ImagePreviewButton(
            onTap: selectImage,
            file: imgFile,
            imgURL: null,
            height: screenWidth(context),
            width: screenWidth(context),
          );
  }
}

class _SelectedTags extends StatelessWidget {
  final List? tags;
  final String Function(int) removeTagAtIndex;
  _SelectedTags({this.tags, required this.removeTagAtIndex});

  @override
  Widget build(BuildContext context) {
    return tags == null || tags!.isEmpty
        ? Container()
        : Container(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tags!.length,
              itemBuilder: (BuildContext context, int index) {
                return RemovableTagButton(onTap: () => removeTagAtIndex(index), tag: tags![index]);
              },
            ),
          );
  }
}

class _PostAddressAutoComplete extends HookViewModelWidget<CreatePostViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreatePostViewModel model) {
    return AutoCompleteAddressTextField(
      initialValue: model.post.city == null ? "" : model.post.city!,
      hintText: "Address",
      onSelectedAddress: (val) => model.updateLocation(val),
    );
  }
}

class _PostMessageField extends HookViewModelWidget<CreatePostViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreatePostViewModel model) {
    var description = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (model.isEditing && !model.loadedPreviousMessage) {
        description.text = model.loadPreviousMessage();
      }
    });

    return MultiLineTextField(
      enabled: model.textFieldEnabled,
      controller: description,
      hintText: "Don't Be Shy...",
      initialValue: null,
      maxLines: 5,
      onChanged: (val) {
        description.selection = TextSelection.fromPosition(TextPosition(offset: description.text.length));
        model.updatePostMessage(val);
      },
    );
  }
}
