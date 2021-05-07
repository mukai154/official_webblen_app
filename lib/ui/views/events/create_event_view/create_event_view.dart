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
import 'package:webblen/ui/views/events/create_event_view/create_event_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/add_image_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
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
import 'package:webblen/ui/widgets/events/event_venue_size_slider.dart';
import 'package:webblen/ui/widgets/events/ticketing_fees_and_discount_forms/discount_form.dart';
import 'package:webblen/ui/widgets/events/ticketing_fees_and_discount_forms/fee_form.dart';
import 'package:webblen/ui/widgets/events/ticketing_fees_and_discount_forms/ticketing_form.dart';
import 'package:webblen/ui/widgets/list_builders/list_discounts/list_discounts.dart';
import 'package:webblen/ui/widgets/list_builders/list_fees/list_fees.dart';
import 'package:webblen/ui/widgets/list_builders/list_tickets/list_tickets.dart';
import 'package:webblen/ui/widgets/tags/tag_auto_complete_field.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/ui/widgets/wallet/stripe/create_earnings_account/create_earnings_account_block_view.dart';

class CreateEventView extends StatelessWidget {
  final String? id;
  final String? promo;
  CreateEventView(@PathParam() this.id, @PathParam() this.promo);

  Widget appBarLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: AppBarCircleProgressIndicator(color: appActiveColor(), size: 25),
    );
  }

  Widget doneButton(BuildContext context, CreateEventViewModel model) {
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
    return ViewModelBuilder<CreateEventViewModel>.reactive(
      onModelReady: (model) => model.initialize(eventID: id, promoVal: promo),
      viewModelBuilder: () => CreateEventViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: model.isEditing ? 'Edit Event' : 'New Event',
          showBackButton: true,
          onPressedBack: () => model.navigateBack(),
          actionWidget: !model.initialized
              ? Container()
              : model.isBusy
                  ? appBarLoadingIndicator()
                  : doneButton(context, model),
          bottomWidget: model.hasEarningsAccount != null && !model.hasEarningsAccount!
              ? GestureDetector(
                  onTap: () => model.navigateBackToWalletPage(),
                  child: Container(
                    height: 40,
                    width: screenWidth(context),
                    color: CustomColors.darkMountainGreen,
                    child: Center(
                      child: CustomText(
                        text: "Want to Sell Tickets for Your Events?\n Create an Earnings Account!",
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
                          constraints: BoxConstraints(
                            maxWidth: 500,
                          ),
                          child: Column(
                            children: [
                              model.hasEarningsAccount != null && !model.hasEarningsAccount!
                                  ? CreateEarningsAccountBlockView(dismissNotice: () => model.dismissEarningsAccountNotice())
                                  : Container(),

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

                              ///TAGS
                              _SelectedTags(
                                tags: model.event.tags,
                                removeTagAtIndex: (index) => model.removeTagAtIndex(index),
                              ),
                              verticalSpaceMedium,

                              ///FORM FIELDS
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ///TAG AUTOCOMPLETE
                                    _TextFieldHeader(
                                      header: "Tags",
                                      subHeader: "What topics are related to this event?",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    TagAutoCompleteField(
                                      enabled: model.textFieldEnabled,
                                      controller: model.tagTextController,
                                      onTagSelected: (tag) => model.addTag(tag!),
                                    ),
                                    verticalSpaceMedium,

                                    ///TITLE
                                    _TextFieldHeader(
                                      header: "Title",
                                      subHeader: "What is the name of this event?",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventTitleField(),
                                    verticalSpaceMedium,

                                    ///DESCRIPTION
                                    _TextFieldHeader(
                                      header: "Description",
                                      subHeader: "Provide details about the event",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventDescriptionField(),
                                    verticalSpaceMedium,

                                    ///PRIVACY
                                    _TextFieldHeader(
                                      header: "Privacy",
                                      subHeader: "Is this a public or private event?",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventPrivacyDropDownField(),

                                    _FormSectionDivider(sectionName: "LOCATION"),

                                    ///EVENT ADDRESS
                                    _TextFieldHeader(
                                      header: "Address",
                                      subHeader: "Where is this event taking place?",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventAddressAutoComplete(),
                                    verticalSpaceMedium,

                                    ///EVENT VENUE NAME
                                    _TextFieldHeader(
                                      header: "Venue Name",
                                      subHeader: "What is the name of the building/area for the event?",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventVenueNameField(),
                                    verticalSpaceMedium,

                                    ///EVENT VENUE SIZE
                                    _TextFieldHeader(
                                      header: "Venue Size",
                                      subHeader: "What is the size of the venue/area for the event?",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventVenueSizeSlider(),

                                    _FormSectionDivider(sectionName: "DATE & TIME"),

                                    ///EVENT START DATE
                                    _TextFieldHeader(
                                      header: "Start Date & Time",
                                      subHeader: "When does this event start?",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventStartDateSelector(),
                                    verticalSpaceSmall,
                                    _EventStartTimeSelector(),
                                    verticalSpaceMedium,

                                    ///EVENT END DATE
                                    _TextFieldHeader(
                                      header: "End Date & Time",
                                      subHeader: "When does this event end?",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventEndDateSelector(),
                                    verticalSpaceSmall,
                                    _EventEndTimeSelector(),
                                    verticalSpaceMedium,

                                    ///EVENT TIMEZONE
                                    _TextFieldHeader(
                                      header: "Timezone",
                                      subHeader: "Which timezone is the event in?",
                                      required: true,
                                    ),
                                    verticalSpaceSmall,
                                    _EventTimeZoneSelector(),

                                    ///EVENT TICKETING
                                    model.hasEarningsAccount != null && model.hasEarningsAccount! ? _EventTicketingForm() : Container(),

                                    _FormSectionDivider(sectionName: "ADDITIONAL INFO"),

                                    ///STREAM EVENT
                                    _ScheduleLiveStreamCheckBox(),
                                    verticalSpaceSmall,

                                    ///EVENT SPONSORSHIP
                                    _AvailableToSponsorsCheckBox(),
                                    verticalSpaceMedium,

                                    ///SOCIAL ACCOUNTS & WEBSITE
                                    _TextFieldHeader(
                                      header: "Social Accounts & Website",
                                      subHeader: "Link your social accounts and website",
                                      required: false,
                                    ),
                                    verticalSpaceSmall,
                                    _FBUsernameField(),
                                    verticalSpaceSmall,
                                    _InstaUsernameField(),
                                    verticalSpaceSmall,
                                    _TwitterUsernameField(),
                                    verticalSpaceSmall,
                                    _WebsiteField(),
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

class _FormSectionDivider extends StatelessWidget {
  final String sectionName;
  _FormSectionDivider({required this.sectionName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        verticalSpaceMedium,
        verticalSpaceMedium,
        Text(
          sectionName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: appFontColorAlt(),
          ),
        ),
        verticalSpaceSmall,
      ],
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

class _EventTitleField extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    var title = useTextEditingController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousTitle) {
        title.text = model.loadPreviousTitle();
      }
    });
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

class _EventDescriptionField extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
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
        description.selection = TextSelection.fromPosition(TextPosition(offset: description.text.length));
        model.updateDescription(val);
      },
    );
  }
}

class _EventPrivacyDropDownField extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return EventPrivacyDropdown(
      privacy: model.event.privacy,
      onChanged: (val) => model.onSelectedPrivacyFromDropdown(val!),
    );
  }
}

class _EventAddressAutoComplete extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return AutoCompleteAddressTextField(
      initialValue: model.event.streetAddress == null ? "" : model.event.streetAddress!,
      hintText: "Address",
      onSelectedAddress: (val) => model.updateLocation(val),
    );
  }
}

class _EventVenueNameField extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    var venueName = useTextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!model.loadedPreviousVenueName) {
        venueName.text = model.loadPreviousVenueName();
      }
    });

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

class _EventVenueSizeSlider extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return EventVenueSizeSlider(
      initialValue: model.event.venueSize == null ? "Small" : model.event.venueSize!,
      onChanged: (val) => model.updateVenueSize(val),
    );
  }
}

class _EventStartDateSelector extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return GestureDetector(
      onTap: !model.textFieldEnabled ? null : () => model.selectDate(selectingStartDate: true),
      child: SingleLineTextField(
        controller: model.eventStartDateTextController,
        hintText: "Start Date",
        textLimit: null,
        isPassword: false,
        enabled: false,
      ),
    );
  }
}

class _EventStartTimeSelector extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return TimeDropdown(
      selectedTime: model.event.startTime,
      onChanged: (val) => model.onSelectedTimeFromDropdown(selectedStartTime: true, time: val!),
    );
  }
}

class _EventEndDateSelector extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return GestureDetector(
      onTap: !model.textFieldEnabled ? null : () => model.selectDate(selectingStartDate: false),
      child: SingleLineTextField(
        controller: model.eventEndDateTextController,
        hintText: "End Date",
        textLimit: null,
        isPassword: false,
        enabled: false,
      ),
    );
  }
}

class _EventEndTimeSelector extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return TimeDropdown(
      selectedTime: model.event.endTime,
      onChanged: (val) => model.onSelectedTimeFromDropdown(selectedStartTime: false, time: val!),
    );
  }
}

class _EventTimeZoneSelector extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return TimezoneDropdown(
      selectedTimezone: model.event.timezone,
      onChanged: (val) => model.onSelectedTimezoneFromDropdown(val!),
    );
  }
}

class _EventTicketingForm extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormSectionDivider(sectionName: "TICKETING"),

        _TextFieldHeader(
          header: "Ticketing",
          subHeader: "Add ticketing, fees, and discount info for your event",
          required: false,
        ),
        verticalSpaceSmall,

        //list tickets
        model.ticketDistro.tickets!.isEmpty
            ? Container()
            : ListTicketsForEditing(
                ticketDistro: model.ticketDistro,
                editTicketAtIndex: (index) => model.toggleTicketForm(ticketIndex: index),
              ),

        //list fees
        model.ticketDistro.fees!.isEmpty || model.ticketDistro.tickets!.isEmpty ? Container() : verticalSpaceSmall,
        model.ticketDistro.fees!.isEmpty || model.ticketDistro.tickets!.isEmpty
            ? Container()
            : ListFeesForEditing(
                ticketDistro: model.ticketDistro,
                editFeeAtIndex: (index) => model.toggleFeeForm(feeIndex: index),
              ),

        //list discount codes
        model.ticketDistro.discountCodes!.isEmpty || model.ticketDistro.discountCodes!.isEmpty ? Container() : verticalSpaceSmall,
        model.ticketDistro.discountCodes!.isEmpty || model.ticketDistro.discountCodes!.isEmpty
            ? Container()
            : ListDiscountsForEditing(
                ticketDistro: model.ticketDistro,
                editDiscountAtIndex: (index) => model.toggleDiscountsForm(discountIndex: index),
              ),
        verticalSpaceSmall,

        //ticket form
        model.showTicketForm
            ? TicketingForm(
                editingTicket: model.ticketToEditIndex != null ? true : false,
                ticketNameTextController: model.ticketNameTextController,
                ticketQuantityTextController: model.ticketQuantityTextController,
                ticketPriceTextController: model.ticketPriceTextController,
                validateAndSubmitTicket: () => model.addTicket(),
                deleteTicket: () => model.deleteTicket(),
              )

            //fee form
            : model.showFeeForm
                ? FeeForm(
                    editingFee: model.feeToEditIndex != null ? true : false,
                    feeNameTextController: model.feeNameTextController,
                    feePriceTextController: model.feePriceTextController,
                    validateAndSubmitFee: () => model.addFee(),
                    deleteFee: () => model.deleteFee(),
                  )

                //discount form
                : model.showDiscountCodeForm
                    ? DiscountForm(
                        editingDiscount: model.discountToEditIndex != null ? true : false,
                        discountNameTextController: model.discountNameTextController,
                        discountLimitTextController: model.discountLimitTextController,
                        discountValueTextController: model.discountValueTextController,
                        validateAndSubmitDiscount: () => model.addDiscount(),
                        deleteDiscount: () => model.deleteDiscount(),
                      )

                    //new ticket, fee, and discount buttons
                    : Container(
                        height: 50,
                        child: Row(
                          children: [
                            CustomIconButton(
                              height: 40,
                              width: 40,
                              icon: Icon(
                                FontAwesomeIcons.ticketAlt,
                                size: 16,
                                color: appIconColor(),
                              ),
                              onPressed: () => model.toggleTicketForm(ticketIndex: null),
                              centerContent: true,
                              backgroundColor: appButtonColorAlt(),
                            ),
                            horizontalSpaceSmall,
                            model.ticketDistro.tickets!.isEmpty
                                ? Container()
                                : CustomIconButton(
                                    height: 40,
                                    width: 40,
                                    icon: Icon(
                                      FontAwesomeIcons.dollarSign,
                                      size: 16,
                                      color: appIconColor(),
                                    ),
                                    onPressed: () => model.toggleFeeForm(feeIndex: null),
                                    centerContent: true,
                                    backgroundColor: appButtonColorAlt(),
                                  ),
                            horizontalSpaceSmall,
                            model.ticketDistro.tickets!.isEmpty
                                ? Container()
                                : CustomIconButton(
                                    height: 40,
                                    width: 40,
                                    icon: Icon(
                                      FontAwesomeIcons.percent,
                                      size: 16,
                                      color: appIconColor(),
                                    ),
                                    onPressed: () => model.toggleDiscountsForm(discountIndex: null),
                                    centerContent: true,
                                    backgroundColor: appButtonColorAlt(),
                                  ),
                          ],
                        ),
                      ),
      ],
    );
  }
}

class _ScheduleLiveStreamCheckBox extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return CustomDetailedCheckbox(
      header: "Schedule Live Stream",
      subHeader: "Schedule a live video stream for this event",
      initialValue: model.event.hasStream,
      onChanged: (val) => model.updateVideoStreamStatus(val),
    );
  }
}

class _AvailableToSponsorsCheckBox extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
    return CustomDetailedCheckbox(
      header: "Available for Sponsors",
      subHeader: "Webblen will help acquire sponsors for this event. You will be contacted whenever a suitable sponsor is found.\nSponsors are not "
          "guaranteed.",
      initialValue: model.event.openToSponsors,
      onChanged: (val) => model.updateSponsorshipStatus(val),
    );
  }
}

class _FBUsernameField extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
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
            iconData: FontAwesomeIcons.at,
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

class _InstaUsernameField extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
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
            iconData: FontAwesomeIcons.at,
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

class _TwitterUsernameField extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
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
            iconData: FontAwesomeIcons.at,
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

class _WebsiteField extends HookViewModelWidget<CreateEventViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, CreateEventViewModel model) {
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
