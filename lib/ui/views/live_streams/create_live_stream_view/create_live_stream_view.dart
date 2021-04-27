import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
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
import 'package:webblen/ui/widgets/events/ticketing_fees_and_discount_forms/discount_form.dart';
import 'package:webblen/ui/widgets/events/ticketing_fees_and_discount_forms/fee_form.dart';
import 'package:webblen/ui/widgets/events/ticketing_fees_and_discount_forms/ticketing_form.dart';
import 'package:webblen/ui/widgets/list_builders/list_discounts.dart';
import 'package:webblen/ui/widgets/list_builders/list_fees.dart';
import 'package:webblen/ui/widgets/list_builders/list_tickets.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/ui/widgets/tags/tag_dropdown_field.dart';

import 'create_live_stream_view_model.dart';

class CreateLiveStreamView extends StatelessWidget {
  Widget selectedTags(CreateLiveStreamViewModel model) {
    return model.stream!.tags == null || model.stream!.tags!.isEmpty
        ? Container()
        : Container(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: model.stream!.tags!.length,
              itemBuilder: (BuildContext context, int index) {
                return RemovableTagButton(onTap: () => model.removeTagAtIndex(index), tag: model.stream!.tags![index]);
              },
            ),
          );
  }

  Widget textFieldHeader({required String header, required String subHeader, required bool required}) {
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
            imgURL: model.stream!.imageURL,
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

  Widget formSectionDivider({required String sectionName}) {
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

  Widget form(BuildContext context, CreateLiveStreamViewModel model) {
    return Container(
      height: screenHeight(context),
      child: ListView(
        shrinkWrap: true,
        children: [
          ///POST IMAGE
          model.img == null && model.stream!.imageURL == null ? imgBtn(context, model) : imgPreview(context, model),
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
                ///EVENT TAGS
                textFieldHeader(
                  header: "Tags",
                  subHeader: "What topics are related to this stream?",
                  required: true,
                ),
                verticalSpaceSmall,
                TagDropdownField(
                  enabled: model.textFieldEnabled,
                  controller: model.tagTextController,
                  onTagSelected: (tag) => model.addTag(tag),
                ),
                verticalSpaceMedium,

                ///EVENT TITLE
                textFieldHeader(
                  header: "Title",
                  subHeader: "What is the name of this stream?",
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
                  subHeader: "Provide details about the stream",
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
                  subHeader: "Is this a public or private event?",
                  required: true,
                ),
                verticalSpaceSmall,
                EventPrivacyDropdown(
                  privacy: model.stream!.privacy,
                  onChanged: (val) => model.onSelectedPrivacyFromDropdown(val),
                ),

                formSectionDivider(sectionName: "AUDIENCE LOCATION, DATE, & TIME"),

                ///STREAM AUDIENCE LOCATION
                textFieldHeader(
                  header: "Audience Location",
                  subHeader: "Where is your target audience located?",
                  required: true,
                ),
                verticalSpaceSmall,
                AutoCompleteAddressTextField(
                  initialValue: model.stream!.audienceLocation,
                  hintText: "Location",
                  onSelectedAddress: (val) => model.setStreamAudienceLocation(val),
                ),
                verticalSpaceMedium,

                ///STREAM START DATE
                textFieldHeader(
                  header: "Start Date & Time",
                  subHeader: "When will this stream start?",
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
                  selectedTime: model.stream!.startTime,
                  onChanged: (val) => model.onSelectedTimeFromDropdown(selectedStartTime: true, time: val),
                ),
                verticalSpaceMedium,

                ///EVENT END DATE
                textFieldHeader(
                  header: "End Date & Time",
                  subHeader: "When will this stream end?",
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
                  selectedTime: model.stream!.endTime,
                  onChanged: (val) => model.onSelectedTimeFromDropdown(selectedStartTime: false, time: val),
                ),
                verticalSpaceMedium,

                ///EVENT TIMEZONE
                textFieldHeader(
                  header: "Timezone",
                  subHeader: "Which timezone is the stream in?",
                  required: true,
                ),
                verticalSpaceSmall,
                TimezoneDropdown(
                  selectedTimezone: model.stream!.timezone,
                  onChanged: (val) => model.onSelectedTimezoneFromDropdown(val),
                ),

                ///EVENT TICKETING, FEES, AND DISCOUNTS
                model.hasEarningsAccount == null || !model.hasEarningsAccount!
                    ? Container()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          formSectionDivider(sectionName: "TICKETING"),

                          textFieldHeader(
                            header: "Ticketing",
                            subHeader: "Add ticketing, fees, and discount info for your event",
                            required: false,
                          ),
                          verticalSpaceSmall,

                          //list tickets
                          model.ticketDistro!.tickets!.isEmpty
                              ? Container()
                              : ListTicketsForEditing(
                                  ticketDistro: model.ticketDistro,
                                  editTicketAtIndex: (index) => model.toggleTicketForm(ticketIndex: index),
                                ),

                          //list fees
                          model.ticketDistro!.fees!.isEmpty || model.ticketDistro!.tickets!.isEmpty ? Container() : verticalSpaceSmall,
                          model.ticketDistro!.fees!.isEmpty || model.ticketDistro!.tickets!.isEmpty
                              ? Container()
                              : ListFeesForEditing(
                                  ticketDistro: model.ticketDistro,
                                  editFeeAtIndex: (index) => model.toggleFeeForm(feeIndex: index),
                                ),

                          //list discount codes
                          model.ticketDistro!.discountCodes!.isEmpty || model.ticketDistro!.discountCodes!.isEmpty ? Container() : verticalSpaceSmall,
                          model.ticketDistro!.discountCodes!.isEmpty || model.ticketDistro!.discountCodes!.isEmpty
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
                                              model.ticketDistro!.tickets!.isEmpty
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
                                              model.ticketDistro!.tickets!.isEmpty
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
                      ),

                formSectionDivider(sectionName: "ADDITIONAL INFO"),

                ///EVENT SPONSORSHIP
                CustomDetailedCheckbox(
                  header: "Available for Sponsors",
                  subHeader: "Webblen will acquire sponsors for this stream. You will be contacted whenever a suitable sponsor is found.\nSponsors are not "
                      "guaranteed.",
                  initialValue: model.stream!.openToSponsors,
                  onChanged: (val) => model.setSponsorshipStatus(val),
                ),
                verticalSpaceMedium,

                ///SOCIAL ACCOUNTS & WEBSITE
                textFieldHeader(
                  header: "Social Accounts & Website",
                  subHeader: "Link your social accounts and website",
                  required: false,
                ),
                verticalSpaceSmall,
                Container(
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
                        size: 24,
                      ),
                      horizontalSpaceSmall,
                      IconTextField(
                        iconData: FontAwesomeIcons.at,
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
                        size: 24,
                      ),
                      horizontalSpaceSmall,
                      IconTextField(
                        iconData: FontAwesomeIcons.at,
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
                        FontAwesomeIcons.link,
                        color: appFontColor(),
                        size: 24,
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
                verticalSpaceMassive,
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
      onModelReady: (model) => model.initialize(context: context),
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
        ) as PreferredSizeWidget?,
        //CustomAppBar().a(title: "New Post", showBackButton: true),
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
