import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

import 'event_block_view_model.dart';

class EventBlockWidget extends StatelessWidget {
  final WebblenEvent event;
  final Function(WebblenEvent) showEventOptions;

  EventBlockWidget({required this.event, required this.showEventOptions});

  Widget eventStartDate(EventBlockViewModel model) {
    return Container(
      width: 50,
      child: Column(
        children: [
          SizedBox(height: 16),
          CustomText(
            text: event.startDate!.substring(4, event.startDate!.length - 6),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          CustomText(
            text: event.startDate!.substring(0, event.startDate!.length - 9),
            color: appFontColorAlt(),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          verticalSpaceTiny,
          GestureDetector(
            onTap: () => model.saveUnsaveEvent(eventID: event.id),
            child: Icon(
              model.savedEvent ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              size: 18,
              color: model.savedEvent ? appSavedContentColor() : appIconColorAlt(),
            ),
          ),
        ],
      ),
    );
  }

  Widget eventBody(BuildContext context, EventBlockViewModel model) {
    return Container(
      width: screenWidth(context) - 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: screenWidth(context) - 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  event.imageURL!,
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
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => model.navigateToUserView(event.authorID),
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
                                  color: appFontColor(),
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
                                onPressed: () => showEventOptions(event),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: event.title,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        verticalSpaceTiny,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: "${event.city}, ${event.province}",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            model.eventIsHappeningNow
                                ? Container(
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
                                : Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        CustomText(
                                          text: "${event.startTime} - ${event.endTime}",
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                        verticalSpaceSmall,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          eventTags(model),
        ],
      ),
    );
  }

  Widget eventTags(EventBlockViewModel model) {
    return event.tags == null || event.tags!.isEmpty
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
              itemCount: event.tags!.length,
              itemBuilder: (context, index) {
                return TagButton(
                  onTap: null,
                  tag: event.tags![index],
                );
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EventBlockViewModel>.reactive(
      onModelReady: (model) => model.initialize(event),
      viewModelBuilder: () => EventBlockViewModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : Container(
              height: 330,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: GestureDetector(
                onDoubleTap: () => model.saveUnsaveEvent(eventID: event.id),
                onLongPress: () {
                  HapticFeedback.lightImpact();
                  showEventOptions(event);
                },
                onTap: () => model.navigateToEventView(eventID: event.id),
                child: Row(
                  children: [
                    eventStartDate(model),
                    horizontalSpaceSmall,
                    eventBody(context, model),
                  ],
                ),
              ),
            ),
    );
  }
}
