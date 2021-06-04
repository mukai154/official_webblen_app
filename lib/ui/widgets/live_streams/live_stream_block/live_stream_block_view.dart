import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/live_streams/live_stream_block/live_stream_block_view_model.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

class LiveStreamBlockView extends StatelessWidget {
  final WebblenLiveStream stream;
  final Function(WebblenLiveStream) showStreamOptions;

  LiveStreamBlockView({required this.stream, required this.showStreamOptions});

  Widget streamBody(BuildContext context, LiveStreamBlockViewModel model) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 275,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  stream.imageURL!,
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
                          onTap: () => model.customNavigationService.navigateToUserView(stream.hostID!),
                          child: Container(
                            child: Row(
                              children: [
                                UserProfilePic(
                                  userPicUrl: model.hostImageURL,
                                  size: 30,
                                  isBusy: false,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                CustomText(
                                  text: "@${model.hostUsername}",
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
                                icon: Icon(
                                  FontAwesomeIcons.solidHeart,
                                  size: 18,
                                  color: model.savedStream ? appSavedContentColor() : Colors.white54,
                                ),
                                onPressed: () => model.saveUnsaveStream(stream: stream),
                              ),
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
                          text: stream.title,
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        verticalSpaceTiny,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: "${stream.city}, ${stream.province}",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            model.isLive
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
                                          text: "${stream.startDate!.substring(0, stream.startDate!.length - 6)} - ${stream.startTime} ${stream.timezone}",
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
          streamTags(model),
        ],
      ),
    );
  }

  Widget streamTags(LiveStreamBlockViewModel model) {
    return stream.tags == null || stream.tags!.isEmpty
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
              itemCount: stream.tags!.length,
              itemBuilder: (context, index) {
                return TagButton(
                  onTap: null,
                  tag: stream.tags![index],
                );
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LiveStreamBlockViewModel>.reactive(
      onModelReady: (model) => model.initialize(stream),
      viewModelBuilder: () => LiveStreamBlockViewModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: GestureDetector(
                onDoubleTap: () => model.saveUnsaveStream(stream: stream),
                onLongPress: () {
                  HapticFeedback.lightImpact();
                  showStreamOptions(stream);
                },
                onTap: () => model.customNavigationService.navigateToLiveStreamView(stream.id!),
                child: streamBody(context, model),
              ),
            ),
    );
  }
}
