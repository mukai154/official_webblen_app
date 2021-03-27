import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/events/event_view/event_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/custom_text_with_links.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

class EventView extends StatelessWidget {
  final FocusNode focusNode = FocusNode();

  Widget sectionDivider({@required String sectionName}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            sectionName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: appFontColorAlt(),
            ),
          ),
          verticalSpaceTiny,
        ],
      ),
    );
  }

  Widget eventHead(EventViewModel model) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () => model.navigateToUserView(model.author.id),
            child: Row(
              children: <Widget>[
                UserProfilePic(
                  isBusy: false,
                  userPicUrl: model.author.profilePicURL,
                  size: 35,
                ),
                horizontalSpaceSmall,
                Text(
                  "@${model.author.username}",
                  style: TextStyle(color: appFontColor(), fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          model.eventIsHappeningNow
              ? Container(
                  width: 120,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: appActiveColor(),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      "Happening Now",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget eventImg(BuildContext context, String url) {
    return CachedNetworkImage(
      imageUrl: url,
      height: screenWidth(context),
      width: screenWidth(context),
      fadeInCurve: Curves.easeIn,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }

  Widget eventTags(EventViewModel model) {
    return model.event.tags == null || model.event.tags.isEmpty
        ? Container()
        : Container(
            margin: EdgeInsets.only(top: 4, bottom: 8, left: 16, right: 16),
            height: 30,
            child: ListView.builder(
              addAutomaticKeepAlives: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: EdgeInsets.only(
                top: 4.0,
                bottom: 4.0,
              ),
              itemCount: model.event.tags.length,
              itemBuilder: (context, index) {
                return TagButton(
                  onTap: null,
                  tag: model.event.tags[index],
                );
              },
            ),
          );
  }

  Widget eventDesc(EventViewModel model) {
    List<TextSpan> linkifiedText = [];

    linkifiedText.addAll(linkify(text: model.event.description.trim(), fontSize: 16));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: RichText(
        text: TextSpan(
          children: linkifiedText,
        ),
      ),
    );
  }

  Widget eventDateAndTime(EventViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "${model.event.startDate} | ${model.event.startTime} - ${model.event.endTime} ${model.event.timezone}",
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: appFontColor(),
          ),
          verticalSpaceTiny,
          CustomTextButton(
            onTap: () => model.addToCalendar(),
            text: "Add to Calendar",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: appTextButtonColor(),
          ),
        ],
      ),
    );
  }

  Widget eventLocation(EventViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: model.event.venueName,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: appFontColor(),
          ),
          verticalSpaceTiny,
          CustomText(
            text: model.event.streetAddress,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: appFontColor(),
          ),
          verticalSpaceTiny,
          CustomTextButton(
            onTap: () => model.openMaps(),
            text: "View in Maps",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: appTextButtonColor(),
          ),
        ],
      ),
    );
  }

  Widget eventSocialAccounts(EventViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpaceTiny,
          Row(
            children: [
              model.event.fbUsername == null || model.event.fbUsername.isEmpty
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () => model.openFacebook(),
                        child: Icon(
                          FontAwesomeIcons.facebook,
                          size: 30,
                          color: appIconColor(),
                        ),
                      ),
                    ),
              model.event.instaUsername == null || model.event.instaUsername.isEmpty
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () => model.openInstagram(),
                        child: Icon(
                          FontAwesomeIcons.instagram,
                          size: 30,
                          color: appIconColor(),
                        ),
                      ),
                    ),
              model.event.twitterUsername == null || model.event.twitterUsername.isEmpty
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () => model.openTwitter(),
                        child: Icon(
                          FontAwesomeIcons.twitter,
                          size: 30,
                          color: appIconColor(),
                        ),
                      ),
                    ),
              model.event.website == null || model.event.website.isEmpty
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () => model.openWebsite(),
                        child: Icon(
                          FontAwesomeIcons.link,
                          size: 30,
                          color: appIconColor(),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget eventBody(BuildContext context, EventViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          verticalSpaceSmall,
          eventHead(model),
          verticalSpaceSmall,
          eventImg(context, model.event.imageURL),
          eventTags(model),
          verticalSpaceSmall,
          sectionDivider(sectionName: "Details"),
          eventDesc(model),
          verticalSpaceMedium,
          sectionDivider(sectionName: "Date & Time"),
          eventDateAndTime(model),
          verticalSpaceMedium,
          sectionDivider(sectionName: "Location"),
          eventLocation(model),
          verticalSpaceMedium,
          model.hasSocialAccounts ? sectionDivider(sectionName: "Social Accounts & Websites") : Container(),
          eventSocialAccounts(model),
          verticalSpaceMedium,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EventViewModel>.reactive(
      onModelReady: (model) => model.initialize(context),
      viewModelBuilder: () => EventViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: "Event",
          showBackButton: true,
          actionWidget: IconButton(
            onPressed: () => model.showContentOptions(),
            icon: Icon(
              FontAwesomeIcons.ellipsisH,
              size: 16,
              color: appIconColor(),
            ),
          ),
        ),
        body: Container(
          height: screenHeight(context),
          color: appBackgroundColor(),
          child: model.isBusy
              ? Container()
              : Stack(
                  children: [
                    LiquidPullToRefresh(
                      backgroundColor: appBackgroundColor(),
                      onRefresh: () async {},
                      child: ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: null,
                        shrinkWrap: true,
                        children: [
                          eventBody(context, model),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: Container(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
