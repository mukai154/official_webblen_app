import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

import 'event_check_in_block_model.dart';

class EventCheckInBlock extends StatelessWidget {
  final WebblenEvent event;
  final Function(WebblenEvent) showEventOptions;

  EventCheckInBlock({required this.event, required this.showEventOptions});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EventCheckInBlockModel>.reactive(
      onModelReady: (model) => model.initialize(event),
      viewModelBuilder: () => EventCheckInBlockModel(),
      builder: (context, model, child) => model.isBusy || !model.event.isValid()
          ? Container()
          : Container(
              margin: EdgeInsets.only(top: 4, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CheckInBlockBody(),
                  _AssociatedTags(),
                ],
              ),
            ),
    );
  }
}

class _CheckInBlockBody extends HookViewModelWidget<EventCheckInBlockModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, EventCheckInBlockModel model) {
    return GestureDetector(
      onTap: () => model.customNavigationService.navigateToEventView(model.event.id!),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(
              model.event.imageURL!,
            ),
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(.8),
                Colors.black.withOpacity(.4),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _CheckInBlockHead(),
              _CheckInBlockInfoAndCheckInButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInBlockHead extends HookViewModelWidget<EventCheckInBlockModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, EventCheckInBlockModel model) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => model.customNavigationService.navigateToUserView(model.event.authorID!),
            child: Container(
              child: Row(
                children: [
                  UserProfilePic(
                    userPicUrl: model.authorImageURL,
                    size: 30,
                    isBusy: false,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  CustomText(
                    text: "@${model.authorUsername}",
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.more_horiz, color: Colors.white),
                  onPressed: () => model.customBottomSheetService.showContentOptions(content: model.event),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInBlockInfoAndCheckInButton extends HookViewModelWidget<EventCheckInBlockModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, EventCheckInBlockModel model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: model.event.title,
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          verticalSpaceTiny,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "${model.event.city}, ${model.event.province}",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              model.event.hasTickets!
                  ? CustomButton(
                      text: "Tickets Required",
                      textColor: appFontColorAlt(),
                      textSize: 16,
                      backgroundColor: appTextFieldContainerColor(),
                      height: 40,
                      width: 200,
                      elevation: 0,
                      onPressed: () {},
                      isBusy: false,
                    )
                  : CustomButton(
                      text: model.checkedIn ? "Check Out" : "Check In",
                      textColor: Colors.white,
                      textSize: 16,
                      backgroundColor: model.checkedIn ? appDestructiveColor() : CustomColors.darkMountainGreen,
                      height: 40,
                      width: 200,
                      elevation: 1,
                      onPressed: () => model.checkInCheckoutOfEvent(),
                      isBusy: model.updatingCheckIn,
                    ),
            ],
          ),
          verticalSpaceSmall,
        ],
      ),
    );
  }
}

class _AssociatedTags extends HookViewModelWidget<EventCheckInBlockModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, EventCheckInBlockModel model) {
    return model.event.tags == null || model.event.tags!.isEmpty
        ? Container()
        : Container(
            margin: EdgeInsets.only(top: 4, bottom: 8, right: 16),
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
              itemCount: model.event.tags!.length,
              itemBuilder: (context, index) {
                return TagButton(
                  onTap: null,
                  tag: model.event.tags![index],
                );
              },
            ),
          );
  }
}
