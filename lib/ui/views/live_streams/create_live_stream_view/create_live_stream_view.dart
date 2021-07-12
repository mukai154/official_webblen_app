import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/add_image_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/checkbox/custom_check_box.dart';
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

import 'create_live_stream_view_model.dart';

class CreateLiveStreamView extends StatelessWidget {
  final String? id;
  CreateLiveStreamView(@PathParam() this.id);

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
          actionWidget: model.isBusy ? _AppBarLoadingIndicator() : _DoneButton(onTap: () => model.showNewContentConfirmationBottomSheet(context: context)),
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
            child: !model.initialized
                ? Container()
                : Container(
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
                                ///IMAGE
                                model.fileToUpload == null && model.stream.imageURL == null
                                    ? _ImageButton(
                                        selectImage: () => model.selectImage(),
                                      )
                                    : _ImagePreview(
                                        selectImage: () => model.selectImage(),
                                        imgFile: model.fileToUpload,
                                        imageURL: model.stream.imageURL,
                                      ),
                                verticalSpaceMedium,

                                ///POST FIELDS
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ///EVENT TITLE
                                      _TextFieldHeader(
                                        header: "Title",
                                        required: true,
                                      ),
                                      verticalSpaceTiny,
                                      _TitleField(),
                                      verticalSpaceMedium,

                                      ///STREAM BODY
                                      _TextFieldHeader(
                                        header: "Description",
                                        required: true,
                                      ),
                                      verticalSpaceTiny,
                                      _DescriptionField(),
                                      verticalSpaceMedium,

                                      ///EVENT PRIVACY
                                      _TextFieldHeader(
                                        header: "Privacy",
                                        required: true,
                                      ),
                                      verticalSpaceTiny,
                                      _PrivacyDropDownField(),

                                      _FormSectionDivider(),

                                      ///STREAM AUDIENCE LOCATION
                                      _TextFieldHeader(
                                        header: "Audience Location",
                                        required: true,
                                      ),
                                      verticalSpaceSmall,
                                      _LocationAutoComplete(),
                                      verticalSpaceMedium,

                                      ///STREAM START DATE
                                      _TextFieldHeader(
                                        header: "Start Date & Time",
                                        required: true,
                                      ),
                                      verticalSpaceSmall,
                                      _StartDateSelector(),
                                      verticalSpaceSmall,
                                      _StartTimeSelector(),
                                      verticalSpaceMedium,

                                      ///EVENT END DATE
                                      _TextFieldHeader(
                                        header: "End Date & Time",
                                        required: true,
                                      ),
                                      verticalSpaceSmall,
                                      _EndDateSelector(),
                                      verticalSpaceSmall,
                                      _EndTimeSelector(),
                                      verticalSpaceMedium,

                                      ///EVENT TIMEZONE
                                      _TextFieldHeader(
                                        header: "Timezone",
                                        required: true,
                                      ),
                                      verticalSpaceSmall,
                                      _TimeZoneSelector(),

                                      _FormSectionDivider(),

                                      ///SOCIAL ACCOUNTS & WEBSITE
                                      _TextFieldHeader(
                                        header: "Social Accounts & Website",
                                        required: false,
                                      ),
                                      verticalSpaceSmall,
                                      _FBUsernameField(),
                                      verticalSpaceSmall,
                                      _InstaUsernameField(),
                                      verticalSpaceSmall,
                                      _TwitterUsernameField(),
                                      verticalSpaceSmall,
                                      _TwitchUsernameField(),
                                      verticalSpaceSmall,
                                      _YoutubeField(),
                                      verticalSpaceSmall,
                                      _WebsiteField(),
                                      verticalSpaceMedium,

                                      ///STREAM KEYS
                                      _TextFieldHeader(
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
                                      _FBStreamKeyField(),
                                      verticalSpaceSmall,
                                      _TwitchStreamKeyField(),
                                      verticalSpaceSmall,
                                      _YoutubeStreamKeyField(),
                                      verticalSpaceMedium,

                                      ///SPONSORSHIP
                                      _AvailableToSponsorsCheckBox(),
                                      verticalSpaceLarge,
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

class _TitleField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var title = useTextEditingController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousTitle) {
        title.text = model.loadPreviousTitle();
      }
    });
    //title.text = model.stream.title != null ? model.stream.title! : "";
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

class _DescriptionField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var description = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousDescription) {
        description.text = model.loadPreviousDesc();
      }
    });

    return MultiLineTextField(
      enabled: model.textFieldEnabled,
      controller: description,
      hintText: "Description",
      initialValue: null,
      maxLines: null,
      onChanged: (val) {
        model.updateDescription(val);
      },
    );
  }
}

class _PrivacyDropDownField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    return EventPrivacyDropdown(
      privacy: model.stream.privacy,
      onChanged: (val) => model.onSelectedPrivacyFromDropdown(val!),
    );
  }
}

class _LocationAutoComplete extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    return AutoCompleteAddressTextField(
      initialValue: model.stream.audienceLocation == null ? "" : model.stream.audienceLocation!,
      hintText: "Audience Location",
      showCurrentLocationButton: true,
      onSelectedAddress: (val) => model.updateLocation(val),
    );
  }
}

class _StartDateSelector extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    return GestureDetector(
      onTap: !model.textFieldEnabled ? null : () => model.selectDate(selectingStartDate: true),
      child: SingleLineTextField(
        controller: model.startDateTextController,
        hintText: "Start Date",
        textLimit: null,
        isPassword: false,
        enabled: false,
      ),
    );
  }
}

class _StartTimeSelector extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    return TimeDropdown(
      selectedTime: model.stream.startTime,
      onChanged: (val) => model.onSelectedTimeFromDropdown(selectedStartTime: true, time: val!),
    );
  }
}

class _EndDateSelector extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    return GestureDetector(
      onTap: !model.textFieldEnabled ? null : () => model.selectDate(selectingStartDate: false),
      child: SingleLineTextField(
        controller: model.endDateTextController,
        hintText: "End Date",
        textLimit: null,
        isPassword: false,
        enabled: false,
      ),
    );
  }
}

class _EndTimeSelector extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    return TimeDropdown(
      selectedTime: model.stream.endTime,
      onChanged: (val) => model.onSelectedTimeFromDropdown(selectedStartTime: false, time: val!),
    );
  }
}

class _TimeZoneSelector extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    return TimezoneDropdown(
      selectedTimezone: model.stream.timezone,
      onChanged: (val) => model.onSelectedTimezoneFromDropdown(val!),
    );
  }
}

class _AvailableToSponsorsCheckBox extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    return model.hasEarningsAccount != null && model.hasEarningsAccount!
        ? CustomDetailedCheckbox(
            header: "Available for Sponsors",
            subHeader: "Webblen will help acquire sponsors for this stream. You will be contacted whenever a suitable sponsor is found.\nSponsors are not "
                "guaranteed.",
            initialValue: model.stream.openToSponsors,
            onChanged: (val) => model.updateSponsorshipStatus(val),
          )
        : Container();
  }
}

class _FBUsernameField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var fbUsername = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousFBUsername) {
        fbUsername.text = model.loadPreviousFBUsername();
      }
    });

    return Container(
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.facebook,
            color: appFontColor(),
            size: 24,
          ),
          horizontalSpaceSmall,
          IconTextField(
            iconData: Icons.alternate_email,
            controller: fbUsername,
            hintText: "Facebook Username",
            onChanged: model.updateFBUsername,
            keyboardType: TextInputType.visiblePassword,
          ),
        ],
      ),
    );
  }
}

class _InstaUsernameField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var instaUsername = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousInstaUsername) {
        instaUsername.text = model.loadPreviousInstaUsername();
      }
    });

    return Container(
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.instagram,
            color: appFontColor(),
            size: 24,
          ),
          horizontalSpaceSmall,
          IconTextField(
            iconData: Icons.alternate_email,
            controller: instaUsername,
            hintText: "Instagram Username",
            onChanged: model.updateInstaUsername,
            keyboardType: TextInputType.visiblePassword,
          ),
        ],
      ),
    );
  }
}

class _TwitterUsernameField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var twitterUsername = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousTwitterUsername) {
        twitterUsername.text = model.loadPreviousTwitterUsername();
      }
    });

    return Container(
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.twitter,
            color: appFontColor(),
            size: 24,
          ),
          horizontalSpaceSmall,
          IconTextField(
            iconData: Icons.alternate_email,
            controller: twitterUsername,
            hintText: "Twitter Username",
            onChanged: model.updateTwitterUsername,
            keyboardType: TextInputType.visiblePassword,
          ),
        ],
      ),
    );
  }
}

class _TwitchUsernameField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var twitchUsername = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousTwitchUsername) {
        twitchUsername.text = model.loadPreviousTwitchUsername();
      }
    });

    return Container(
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.twitch,
            color: appFontColor(),
            size: 24,
          ),
          horizontalSpaceSmall,
          IconTextField(
            iconData: Icons.alternate_email,
            controller: twitchUsername,
            hintText: "Twitch Username",
            onChanged: model.updateTwitchUsername,
            keyboardType: TextInputType.visiblePassword,
          ),
        ],
      ),
    );
  }
}

class _YoutubeField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var youtubeChannel = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousWebsite) {
        youtubeChannel.text = model.loadPreviousWebsite();
      }
    });

    return Container(
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.youtube,
            color: appFontColor(),
            size: 24,
          ),
          horizontalSpaceSmall,
          Expanded(
            child: SingleLineTextField(
              controller: youtubeChannel,
              hintText: "https://youtube.com/channel/mychannel",
              textLimit: null,
              isPassword: false,
              onChanged: model.updateWebsite,
              keyboardType: TextInputType.url,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebsiteField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var website = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousWebsite) {
        website.text = model.loadPreviousWebsite();
      }
    });

    return Container(
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.link,
            color: appFontColor(),
            size: 24,
          ),
          horizontalSpaceSmall,
          Expanded(
            child: SingleLineTextField(
              controller: website,
              hintText: "https://mywebsite.com",
              textLimit: null,
              isPassword: false,
              onChanged: model.updateWebsite,
              keyboardType: TextInputType.url,
            ),
          ),
        ],
      ),
    );
  }
}

class _FBStreamKeyField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var fbStreamKey = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousFBStreamKey) {
        fbStreamKey.text = model.loadPreviousFBStreamKey();
      }
    });

    return Container(
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.facebook,
            color: appFontColor(),
            size: 24,
          ),
          horizontalSpaceSmall,
          Expanded(
            child: SingleLineTextField(
              controller: fbStreamKey,
              hintText: "Facebook Stream Key",
              textLimit: null,
              isPassword: true,
              onChanged: model.updateFBStreamKey,
              keyboardType: TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _TwitchStreamKeyField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var twitchStreamKey = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousTwitchStreamKey) {
        twitchStreamKey.text = model.loadPreviousTwitchStreamKey();
      }
    });

    return Container(
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.twitch,
            color: appFontColor(),
            size: 24,
          ),
          horizontalSpaceSmall,
          Expanded(
            child: SingleLineTextField(
              controller: twitchStreamKey,
              hintText: "Twitch Stream Key",
              textLimit: null,
              isPassword: true,
              onChanged: model.updateTwitchStreamKey,
              keyboardType: TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _YoutubeStreamKeyField extends HookViewModelWidget<CreateLiveStreamViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateLiveStreamViewModel model) {
    var youtubeStreamKey = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousYoutubeStreamKey) {
        youtubeStreamKey.text = model.loadPreviousYoutubeStreamKey();
      }
    });

    return Container(
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.youtube,
            color: appFontColor(),
            size: 24,
          ),
          horizontalSpaceSmall,
          Expanded(
            child: SingleLineTextField(
              controller: youtubeStreamKey,
              hintText: "YouTube Stream Key",
              textLimit: null,
              isPassword: true,
              onChanged: model.updateYoutubeStreamKey,
              keyboardType: TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }
}
