import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/live_streams/live_stream_details_view/live_stream_details_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/custom_text_with_links.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/navigation/nav_bar/custom_bottom_nav_bar.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

class LiveStreamDetailsView extends StatelessWidget {
  final FocusNode focusNode = FocusNode();

  Widget sectionDivider({required String sectionName}) {
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

  Widget streamHead(LiveStreamDetailsViewModel model) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () => model.navigateToUserView(model.host!.id),
            child: Row(
              children: <Widget>[
                UserProfilePic(
                  isBusy: false,
                  userPicUrl: model.host!.profilePicURL,
                  size: 35,
                ),
                horizontalSpaceSmall,
                Text(
                  "@${model.host!.username}",
                  style: TextStyle(color: appFontColor(), fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          model.streamIsLive
              ? Container(
                  width: 120,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: appActiveColor(),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      "LIVE",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget streamImg(BuildContext context, String url) {
    return CachedNetworkImage(
      imageUrl: url,
      height: screenWidth(context),
      width: screenWidth(context),
      fadeInCurve: Curves.easeIn,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }

  Widget streamTags(LiveStreamDetailsViewModel model) {
    return model.stream.tags == null || model.stream.tags!.isEmpty
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
              itemCount: model.stream.tags!.length,
              itemBuilder: (context, index) {
                return TagButton(
                  onTap: null,
                  tag: model.stream.tags![index],
                );
              },
            ),
          );
  }

  Widget streamDesc(LiveStreamDetailsViewModel model) {
    List<TextSpan> linkifiedText = [];

    linkifiedText.addAll(linkify(text: model.stream.description!.trim(), fontSize: 16));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: RichText(
        text: TextSpan(
          children: linkifiedText,
        ),
      ),
    );
  }

  Widget streamDateAndTime(LiveStreamDetailsViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "${model.stream.startDate} | ${model.stream.startTime} - ${model.stream.endTime} ${model.stream.timezone}",
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

  // Widget streamLocation(LiveStreamDetailsViewModel model) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         CustomText(
  //           text: model.event.streetAddress,
  //           fontSize: 16,
  //           fontWeight: FontWeight.w500,
  //           color: appFontColor(),
  //         ),
  //         verticalSpaceTiny,
  //         CustomTextButton(
  //           onTap: () => model.openMaps(),
  //           text: "View in Maps",
  //           fontSize: 14,
  //           fontWeight: FontWeight.bold,
  //           color: appTextButtonColor(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget streamSocialAccounts(LiveStreamDetailsViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpaceTiny,
          Row(
            children: [
              model.stream.fbUsername == null || model.stream.fbUsername!.isEmpty
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
              model.stream.instaUsername == null || model.stream.instaUsername!.isEmpty
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
              model.stream.twitterUsername == null || model.stream.twitterUsername!.isEmpty
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
              model.stream.website == null || model.stream.website!.isEmpty
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

  Widget eventBody(BuildContext context, LiveStreamDetailsViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          verticalSpaceSmall,
          streamHead(model),
          verticalSpaceSmall,
          streamImg(context, model.stream.imageURL!),
          streamTags(model),
          verticalSpaceSmall,
          sectionDivider(sectionName: "Details"),
          streamDesc(model),
          verticalSpaceMedium,
          sectionDivider(sectionName: "Date & Time"),
          streamDateAndTime(model),
          //verticalSpaceMedium,
          //sectionDivider(sectionName: "Location"),
          //streamLocation(model),
          verticalSpaceMedium,
          model.hasSocialAccounts ? sectionDivider(sectionName: "Social Accounts & Websites") : Container(),
          streamSocialAccounts(model),
          verticalSpaceMedium,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LiveStreamDetailsViewModel>.reactive(
      onModelReady: (model) => model.initialize(context),
      viewModelBuilder: () => LiveStreamDetailsViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: "Stream",
          showBackButton: true,
          actionWidget: IconButton(
            onPressed: () => model.showContentOptions(),
            icon: Icon(
              FontAwesomeIcons.ellipsisH,
              size: 16,
              color: appIconColor(),
            ),
          ),
        ) as PreferredSizeWidget?,
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
        bottomNavigationBar: model.isHost
            ? CustomBottomActionBar(
                header: 'Streaming Live',
                subHeader: "on Webblen",
                buttonTitle: "Stream Now",
                buttonAction: () => model.streamNow(),
              )
            : CustomBottomActionBar(
                header: 'Streaming Live',
                subHeader: "on Webblen",
                buttonTitle: "Watch Now",
                buttonAction: () {},
              ),
      ),
    );
  }
}
