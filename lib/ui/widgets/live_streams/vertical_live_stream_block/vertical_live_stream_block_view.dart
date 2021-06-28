import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/live_streams/video_ui/video_streaming_status.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

import 'vertical_live_stream_block_view_model.dart';

class VerticalLiveStreamBlockView extends StatelessWidget {
  final WebblenLiveStream stream;

  VerticalLiveStreamBlockView({required this.stream});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VerticalLiveStreamBlockViewModel>.reactive(
      onModelReady: (model) => model.initialize(stream),
      viewModelBuilder: () => VerticalLiveStreamBlockViewModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : GestureDetector(
              onTap: () => model.navigateToStreamView(stream),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        stream.imageURL!,
                        filterQuality: FilterQuality.medium,
                        height: double.infinity,
                        width: 175,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: double.infinity,
                      width: 175,
                      decoration: BoxDecoration(
                        gradient: CustomColors.livestreamBlockGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: UserProfilePic(
                        size: 30,
                        userPicUrl: model.hostImageURL,
                        isBusy: model.isBusy,
                        hasBorder: model.user.isValid()
                            ? model.clickedBy.contains(model.user.id!)
                                ? false
                                : true
                            : true,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 175,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "${model.hostUsername}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            CustomText(
                              text: "${stream.startDate!.substring(0, stream.startDate!.length - 6)} - ${stream.startTime} ${stream.timezone}",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: stream.isLive != null && stream.isLive! ? LiveNowBox() : Container(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
