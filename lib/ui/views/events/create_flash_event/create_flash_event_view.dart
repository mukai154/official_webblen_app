import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/add_image_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/dropdown/timezone_dropdown.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/text_field/auto_complete_address_text_field/auto_complete_address_text_field.dart';
import 'package:webblen/ui/widgets/common/text_field/single_line_text_field.dart';
import 'package:webblen/ui/widgets/events/event_venue_size_slider.dart';

import 'create_flash_event_view_model.dart';

class CreateFlashEventView extends StatelessWidget {
  final String? id;
  final String? promo;
  CreateFlashEventView(@PathParam() this.id, @PathParam() this.promo);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateFlashEventViewModel>.reactive(
      onModelReady: (model) => model.initialize(eventID: id, promoVal: promo),
      viewModelBuilder: () => CreateFlashEventViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: 'Flash Event',
          showBackButton: true,
          onPressedBack: () => model.navigateBack(),
          actionWidget: !model.initialized
              ? Container()
              : model.isBusy
                  ? _AppBarLoadingIndicator()
                  : _DoneButton(onTap: () => model.showNewContentConfirmationBottomSheet(context: context)),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: screenHeight(context),
            color: appBackgroundColor(),
            child: !model.initialized
                ? Center(
                    child: CustomCircleProgressIndicator(
                      size: 10,
                      color: appActiveColor(),
                    ),
                  )
                : ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          child: Column(
                            children: [
                              ///IMAGE
                              model.fileToUpload == null && model.event.imageURL == null
                                  ? _ImageButton(
                                      selectImage: () => model.selectImage(),
                                    )
                                  : _ImagePreview(
                                      selectImage: () => model.selectImage(),
                                      imgFile: model.fileToUpload,
                                      imageURL: model.event.imageURL,
                                    ),
                              verticalSpaceMedium,

                              ///FORM FIELDS
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ///TITLE
                                    _TextFieldHeader(
                                      header: "Title",
                                      required: true,
                                    ),
                                    verticalSpaceTiny,
                                    _EventTitleField(),

                                    _FormSectionDivider(),

                                    ///EVENT ADDRESS
                                    _TextFieldHeader(
                                      header: "Address",
                                      required: true,
                                    ),
                                    verticalSpaceTiny,
                                    _EventAddressAutoComplete(),
                                    verticalSpaceMedium,

                                    ///EVENT VENUE NAME
                                    _TextFieldHeader(
                                      header: "Venue Name",
                                      required: true,
                                    ),
                                    verticalSpaceTiny,
                                    _EventVenueNameField(),
                                    verticalSpaceMedium,

                                    ///EVENT VENUE SIZE
                                    _TextFieldHeader(
                                      header: "Venue Size",
                                      required: true,
                                    ),
                                    verticalSpaceTiny,
                                    _EventVenueSizeSlider(),

                                    _FormSectionDivider(),

                                    ///EVENT TIMEZONE
                                    _TextFieldHeader(
                                      header: "Timezone",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventTimeZoneSelector(),
                                    verticalSpaceMedium,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _AppBarLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: AppBarCircleProgressIndicator(color: appActiveColor(), size: 25),
    );
  }
}

class _DoneButton extends StatelessWidget {
  final VoidCallback onTap;
  _DoneButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16, top: 18),
      child: CustomTextButton(
        onTap: onTap,
        color: appFontColor(),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        text: 'Done',
        textAlign: TextAlign.right,
      ),
    );
  }
}

class _FormSectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 80);
  }
}

class _TextFieldHeader extends StatelessWidget {
  final String header;
  final bool required;
  _TextFieldHeader({required this.header, required this.required});

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
      isOptional: false,
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

class _EventTitleField extends HookViewModelWidget<CreateFlashEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateFlashEventViewModel model) {
    var title = useTextEditingController();

    //title.text = model.event.title != null ? model.event.title! : "";
    return SingleLineTextField(
      controller: title,
      hintText: "Title",
      textLimit: 100,
      isPassword: false,
      enabled: model.textFieldEnabled,
      onChanged: (val) {
        title.selection = TextSelection.fromPosition(TextPosition(offset: title.text.length));
        model.updateTitle(val);
      },
    );
  }
}

class _EventAddressAutoComplete extends HookViewModelWidget<CreateFlashEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateFlashEventViewModel model) {
    return AutoCompleteAddressTextField(
      initialValue: model.event.streetAddress == null ? "" : model.event.streetAddress!,
      hintText: "Address",
      showCurrentLocationButton: true,
      onSelectedAddress: (val) => model.updateLocation(val),
    );
  }
}

class _EventVenueNameField extends HookViewModelWidget<CreateFlashEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateFlashEventViewModel model) {
    var venueName = useTextEditingController();

    return SingleLineTextField(
      controller: venueName,
      hintText: "Venue Name",
      textLimit: 100,
      isPassword: false,
      enabled: model.textFieldEnabled,
      onChanged: (val) {
        venueName.selection = TextSelection.fromPosition(TextPosition(offset: venueName.text.length));
        model.updateVenueName(val);
      },
    );
  }
}

class _EventVenueSizeSlider extends HookViewModelWidget<CreateFlashEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateFlashEventViewModel model) {
    return EventVenueSizeSlider(
      initialValue: model.event.venueSize == null ? "Small" : model.event.venueSize!,
      onChanged: (val) => model.updateVenueSize(val),
    );
  }
}

class _EventTimeZoneSelector extends HookViewModelWidget<CreateFlashEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateFlashEventViewModel model) {
    return TimezoneDropdown(
      selectedTimezone: model.event.timezone,
      onChanged: (val) => model.onSelectedTimezoneFromDropdown(val!),
    );
  }
}
