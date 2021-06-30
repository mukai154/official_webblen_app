import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/add_image_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/dropdown/event_privacy_dropdown.dart';
import 'package:webblen/ui/widgets/common/dropdown/time_dropdown.dart';
import 'package:webblen/ui/widgets/common/dropdown/timezone_dropdown.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/text_field/auto_complete_address_text_field/auto_complete_address_text_field.dart';
import 'package:webblen/ui/widgets/common/text_field/icon_text_field.dart';
import 'package:webblen/ui/widgets/common/text_field/multi_line_text_field.dart';
import 'package:webblen/ui/widgets/common/text_field/single_line_text_field.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';

import 'create_live_stream_view_model.dart';

class CreateLiveStreamView extends StatelessWidget {
  final String? id;
  CreateLiveStreamView(@PathParam() this.id);

  Widget selectedTags(CreateLiveStreamViewModel model) {
    return model.stream.tags == null || model.stream.tags!.isEmpty
        ? Container()
        : Container(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: model.stream.tags!.length,
              itemBuilder: (BuildContext context, int index) {
                return RemovableTagButton(onTap: () => model.removeTagAtIndex(index), tag: model.stream.tags![index]);
              },
            ),
          );
  }

  Widget textFieldHeader({required String header, required bool required}) {
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
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget imgBtn(BuildContext context, CreateLiveStreamViewModel model) {
    return ImageButton(
      onTap: () => model.selectImage(),
      isOptional: false,
      height: screenWidth(context),
      width: screenWidth(context),
    );
  }

  Widget imgPreview(BuildContext context, CreateLiveStreamViewModel model) {
    return model.img == null
        ? ImagePreviewButton(
            onTap: () => model.selectImage(),
            file: null,
            imgURL: model.stream.imageURL,
            height: screenWidth(context),
            width: screenWidth(context),
          )
        : ImagePreviewButton(
            onTap: () => model.selectImage(),
            file: model.img,
            imgURL: null,
            height: screenWidth(context),
            width: screenWidth(context),
          );
  }

  Widget formSectionDivider() {
    return SizedBox(height: 80);
  }

  Widget form(BuildContext context, CreateLiveStreamViewModel model) {
    return Container(
      height: screenHeight(context),
      child: ListView(
        shrinkWrap: true,
        children: [
          Align(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                children: [
                  ///POST IMAGE
                  model.img == null && model.stream.imageURL == null ? imgBtn(context, model) : imgPreview(context, model),
                  verticalSpaceMedium,

                  ///POST FIELDS
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ///EVENT TITLE
                        textFieldHeader(
                          header: "Title",
                          required: true,
                        ),
                        verticalSpaceSmall,
                        SingleLineTextField(
                          controller: model.titleTextController,
                          hintText: "Title",
                          textLimit: 100,
                          isPassword: false,
                          onChanged: (val) => model.setStreamTitle(val),
                        ),
                        verticalSpaceMedium,

                        ///STREAM BODY
                        textFieldHeader(
                          header: "Description",
                          required: true,
                        ),
                        verticalSpaceSmall,
                        MultiLineTextField(
                          enabled: model.textFieldEnabled,
                          controller: model.descTextController,
                          hintText: "Description",
                          initialValue: null,
                          maxLines: null,
                          onChanged: (val) => model.setStreamDescription(val),
                        ),
                        verticalSpaceMedium,

                        ///EVENT PRIVACY
                        textFieldHeader(
                          header: "Privacy",
                          required: true,
                        ),
                        verticalSpaceSmall,
                        EventPrivacyDropdown(
                          privacy: model.stream.privacy,
                          onChanged: (val) => model.onSelectedPrivacyFromDropdown(val!),
                        ),

                        formSectionDivider(),

                        ///STREAM AUDIENCE LOCATION
                        textFieldHeader(
                          header: "Audience Location",
                          required: true,
                        ),
                        verticalSpaceSmall,
                        AutoCompleteAddressTextField(
                          initialValue: model.stream.audienceLocation == null ? "" : model.stream.audienceLocation!,
                          hintText: "Location",
                          showCurrentLocationButton: true,
                          onSelectedAddress: (val) => model.setStreamAudienceLocation(val),
                        ),
                        verticalSpaceMedium,

                        ///STREAM START DATE
                        textFieldHeader(
                          header: "Start Date & Time",
                          required: true,
                        ),
                        verticalSpaceSmall,
                        GestureDetector(
                          onTap: () => model.selectDate(selectingStartDate: true),
                          child: SingleLineTextField(
                            controller: model.startDateTextController,
                            hintText: "Start Date",
                            textLimit: null,
                            isPassword: false,
                            enabled: false,
                          ),
                        ),
                        verticalSpaceSmall,
                        TimeDropdown(
                          selectedTime: model.stream.startTime,
                          onChanged: (val) => model.onSelectedTimeFromDropdown(selectedStartTime: true, time: val!),
                        ),
                        verticalSpaceMedium,

                        ///EVENT END DATE
                        textFieldHeader(
                          header: "End Date & Time",
                          required: true,
                        ),
                        verticalSpaceSmall,
                        GestureDetector(
                          onTap: () => model.selectDate(selectingStartDate: false),
                          child: SingleLineTextField(
                            controller: model.endDateTextController,
                            hintText: "End Date",
                            textLimit: null,
                            isPassword: false,
                            enabled: false,
                          ),
                        ),
                        verticalSpaceSmall,
                        TimeDropdown(
                          selectedTime: model.stream.endTime,
                          onChanged: (val) => model.onSelectedTimeFromDropdown(selectedStartTime: false, time: val!),
                        ),
                        verticalSpaceMedium,

                        ///EVENT TIMEZONE
                        textFieldHeader(
                          header: "Timezone",
                          required: true,
                        ),
                        verticalSpaceSmall,
                        TimezoneDropdown(
                          selectedTimezone: model.stream.timezone,
                          onChanged: (val) => model.onSelectedTimezoneFromDropdown(val!),
                        ),

                        formSectionDivider(),

                        ///EVENT SPONSORSHIP
                        // CustomDetailedCheckbox(
                        //   header: "Available for Sponsors",
                        //   subHeader:
                        //       "Webblen will acquire sponsors for this stream. You will be contacted whenever a suitable sponsor is found.\nSponsors are not "
                        //       "guaranteed.",
                        //   initialValue: model.stream.openToSponsors ?? false,
                        //   onChanged: (val) => model.setSponsorshipStatus(val),
                        // ),
                        // verticalSpaceMedium,

                        ///SOCIAL ACCOUNTS & WEBSITE
                        textFieldHeader(
                          header: "Social Accounts & Website",
                          required: false,
                        ),
                        verticalSpaceSmall,
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.facebook,
                                color: appFontColor(),
                                size: 20,
                              ),
                              horizontalSpaceSmall,
                              IconTextField(
                                iconData: Icons.alternate_email,
                                controller: model.fbUsernameTextController,
                                hintText: "Facebook Username",
                                onChanged: (val) => model.setFBUsername(val),
                                keyboardType: TextInputType.visiblePassword,
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.instagram,
                                color: appFontColor(),
                                size: 20,
                              ),
                              horizontalSpaceSmall,
                              IconTextField(
                                iconData: Icons.alternate_email,
                                controller: model.instaUsernameTextController,
                                hintText: "Instagram Username",
                                onChanged: (val) => model.setInstaUsername(val),
                                keyboardType: TextInputType.visiblePassword,
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.twitter,
                                color: appFontColor(),
                                size: 20,
                              ),
                              horizontalSpaceSmall,
                              IconTextField(
                                iconData: Icons.alternate_email,
                                controller: model.twitterUsernameTextController,
                                hintText: "Twitter Username",
                                onChanged: (val) => model.setTwitterUsername(val),
                                keyboardType: TextInputType.visiblePassword,
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.twitch,
                                color: appFontColor(),
                                size: 20,
                              ),
                              horizontalSpaceSmall,
                              IconTextField(
                                iconData: Icons.alternate_email,
                                controller: model.twitchTextController,
                                hintText: "Twitch Username",
                                onChanged: (val) => model.setTwitchUsername(val),
                                keyboardType: TextInputType.visiblePassword,
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.youtube,
                                color: appFontColor(),
                                size: 20,
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: SingleLineTextField(
                                  controller: model.youtubeTextController,
                                  hintText: "https://youtube.com/channel/mychannel",
                                  textLimit: null,
                                  isPassword: false,
                                  onChanged: (val) => model.setYoutube(val),
                                  keyboardType: TextInputType.url,
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.link,
                                color: appFontColor(),
                                size: 20,
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: SingleLineTextField(
                                  controller: model.websiteTextController,
                                  hintText: "https://mywebsite.com",
                                  textLimit: null,
                                  isPassword: false,
                                  onChanged: (val) => model.setWebsite(val),
                                  keyboardType: TextInputType.url,
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceMedium,

                        ///STREAM KEYS
                        textFieldHeader(
                          header: "Additional Streams",
                          required: false,
                        ),
                        Text(
                          "Stream on Additional Platforms at the Same Time.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: appFontColorAlt(),
                          ),
                        ),
                        SizedBox(height: 6),
                        CustomTextButton(
                          onTap: () => model.showHowToFindStreamKeys(),
                          text: "Where can I find these?",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: appTextButtonColor(),
                        ),
                        SizedBox(height: 16),
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.facebook,
                                color: appFontColor(),
                                size: 20,
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: SingleLineTextField(
                                  controller: model.fbStreamKeyTextController,
                                  hintText: "Facebook Stream Key",
                                  textLimit: null,
                                  isPassword: true,
                                  onChanged: (val) => model.setFBStreamKey(val),
                                  keyboardType: TextInputType.url,
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.twitch,
                                color: appFontColor(),
                                size: 20,
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: SingleLineTextField(
                                  controller: model.twitchStreamKeyTextController,
                                  hintText: "Twitch Stream Key",
                                  textLimit: null,
                                  isPassword: true,
                                  onChanged: (val) => model.setTwitchStreamKey(val),
                                  keyboardType: TextInputType.url,
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.youtube,
                                color: appFontColor(),
                                size: 20,
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: SingleLineTextField(
                                  controller: model.youtubeStreamKeyTextController,
                                  hintText: "Youtube Stream Key",
                                  textLimit: null,
                                  isPassword: true,
                                  onChanged: (val) => model.setYoutubeStreamKey(val),
                                  keyboardType: TextInputType.url,
                                ),
                              ),
                            ],
                          ),
                        ),
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
    );
  }

  Widget appBarLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: AppBarCircleProgressIndicator(color: appActiveColor(), size: 25),
    );
  }

  Widget doneButton(BuildContext context, CreateLiveStreamViewModel model) {
    return Padding(
      padding: EdgeInsets.only(right: 16, top: 18),
      child: CustomTextButton(
        onTap: () => model.showNewContentConfirmationBottomSheet(context: context),
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
    return ViewModelBuilder<CreateLiveStreamViewModel>.reactive(
      onModelReady: (model) => model.initialize(id!, 0),
      viewModelBuilder: () => CreateLiveStreamViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: model.isEditing ? 'Edit Stream' : 'New Stream',
          showBackButton: true,
          onPressedBack: () => model.navigateBack(),
          actionWidget: model.isBusy ? appBarLoadingIndicator() : doneButton(context, model),
          bottomWidget: model.hasEarningsAccount != null && !model.hasEarningsAccount!
              ? GestureDetector(
                  onTap: () => model.navigateBackToWalletPage(),
                  child: Container(
                    height: 40,
                    width: screenWidth(context),
                    color: CustomColors.darkMountainGreen,
                    child: Center(
                      child: CustomText(
                        text: "Want to Monetize Your Stream with Sponsors?\n Create an Earnings Account!",
                        textAlign: TextAlign.center,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : null,
          bottomWidgetHeight: model.hasEarningsAccount != null && !model.hasEarningsAccount! ? 40 : null,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: screenHeight(context),
            width: screenWidth(context),
            color: appBackgroundColor(),
            child: model.initialized ? form(context, model) : Container(),
          ),
        ),
      ),
    );
  }
}
