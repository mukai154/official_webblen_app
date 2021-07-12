import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:video_player/video_player.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/comments/comment_text_field/comment_text_field_view.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/custom_text_with_links.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/list_builders/list_comments/list_comments.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/utils/time_calc.dart';

import 'expanded_mini_player_view_model.dart';

class ExpandedMiniPlayerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ExpandedMiniPlayerViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ExpandedMiniPlayerViewModel(),
      builder: (context, model, child) => Scaffold(
        body: GestureDetector(
          onTap: () => model.unFocusKeyboard(context),
          child: Container(
            height: screenHeight(context),
            color: appBackgroundColor(),
            child: model.isBusy || model.miniVideoPlayerViewModel.isBusy
                ? Center(
                    child: CustomCircleProgressIndicator(
                      size: 20,
                      color: appActiveColor(),
                    ),
                  )
                : !model.stream.isValid()
                    ? Center(
                        child: CustomCircleProgressIndicator(
                          size: 20,
                          color: appActiveColor(),
                        ),
                      )
                    : Stack(
                        children: [
                          ListView(
                            physics: AlwaysScrollableScrollPhysics(),
                            controller: model.scrollController,
                            shrinkWrap: true,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: screenWidth(context),
                                  ),
                                  child: Column(
                                    children: [
                                      _PortraitVideoPlayer(),
                                      SizedBox(height: 100),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: CommentTextFieldView(
                              onSubmitted: model.isReplying
                                  ? (val) => model.replyToComment(
                                        context: context,
                                        commentData: val,
                                      )
                                  : (val) => model.submitComment(context: context, commentData: val),
                              focusNode: model.focusNode,
                              commentTextController: model.commentTextController,
                              isReplying: model.isReplying,
                              replyReceiverUsername: model.isReplying ? model.commentToReplyTo!.username : null,
                              contentID: '',
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

class _PortraitVideoPlayer extends HookViewModelWidget<ExpandedMiniPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ExpandedMiniPlayerViewModel model) {
    return SafeArea(
      child: Column(
        children: [
          Stack(
            children: [
              Column(
                children: [
                  !model.miniVideoPlayerViewModel.videoPlayerController!.value.isInitialized
                      ? Container(
                          height: 230,
                          child: Center(
                            child: CustomCircleProgressIndicator(
                              size: 20,
                              color: appActiveColor(),
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            GestureDetector(
                              onTap: () => model.miniVideoPlayerViewModel.pausePlayVideoPlayer(),
                              child: AspectRatio(
                                aspectRatio: model.miniVideoPlayerViewModel.videoPlayerController!.value.aspectRatio,
                                child: VideoPlayer(model.miniVideoPlayerViewModel.videoPlayerController!),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 4,
                              child: GestureDetector(
                                onTap: () => model.miniVideoPlayerViewModel.shrinkMiniPlayer(),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white54,
                                  size: 24.0,
                                ),
                              ),
                            ),
                            model.miniVideoPlayerViewModel.videoPlayerController!.value.isPlaying
                                ? Container()
                                : GestureDetector(
                                    onTap: () => model.miniVideoPlayerViewModel.pausePlayVideoPlayer(),
                                    child: AspectRatio(
                                      aspectRatio: model.miniVideoPlayerViewModel.videoPlayerController!.value.aspectRatio,
                                      child: model.miniVideoPlayerViewModel.videoPlayerController!.value.isBuffering
                                          ? Center(
                                              child: CustomCircleProgressIndicator(
                                                size: 20,
                                                color: Colors.white54,
                                              ),
                                            )
                                          : model.miniVideoPlayerViewModel.videoPlayerController!.value.isPlaying
                                              ? Container()
                                              : Center(
                                                  child: Icon(Icons.play_arrow, size: 30, color: Colors.white),
                                                ),
                                    ),
                                  ),
                            Positioned(
                              bottom: 8,
                              left: 4,
                              child: Container(
                                height: 20,
                                width: 20,
                                child: GestureDetector(
                                  onTap: () => model.toggleLandscapeMode(),
                                  child: Icon(
                                    FontAwesomeIcons.expand,
                                    color: Colors.white54,
                                    size: 14.0,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: VideoProgressIndicator(
                                model.miniVideoPlayerViewModel.videoPlayerController!,
                                allowScrubbing: true,
                              ),
                            ),
                          ],
                        ),
                  verticalSpaceSmall,
                  _VideoInfo(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LandscapeVideoPlayer extends HookViewModelWidget<ExpandedMiniPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ExpandedMiniPlayerViewModel model) {
    return !model.miniVideoPlayerViewModel.videoPlayerController!.value.isInitialized
        ? Center(
            child: CustomCircleProgressIndicator(
              size: 20,
              color: appActiveColor(),
            ),
          )
        : Container(
            height: screenHeight(context),
            width: screenWidth(context),
            color: Colors.red,
          );
  }
}

class _VideoInfo extends HookViewModelWidget<ExpandedMiniPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ExpandedMiniPlayerViewModel model) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomText(
                        text: model.stream.title!,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appFontColor(),
                      ),
                      verticalSpaceTiny,
                      CustomText(
                        text:
                            "${model.stream.clickedBy == null ? 0 : model.stream.clickedBy!.length} views • streamed ${TimeCalc().getPastTimeFromMilliseconds(model.stream.startDateTimeInMilliseconds!)}",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appFontColorAlt(),
                      ),
                      verticalSpaceTiny,
                      CustomTextButton(
                        onTap: () => model.navigateToUserView(model.host!.id!),
                        text: "@${model.creatorUsername}",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: appTextButtonColor(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () => model.toggleShowVideoInfo(),
                        iconSize: 24,
                        icon: Icon(
                          model.showVideoInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: appFontColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceSmall,
          model.showVideoInfo
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _VideoDescription(),
                      _VideoTags(),
                    ],
                  ),
                )
              : Container(),
          Divider(
            indent: 16,
            endIndent: 16,
            height: 24,
            thickness: 0.3,
            color: appBorderColor(),
          ),
          _VideoActions(),
          Divider(
            indent: 16,
            endIndent: 16,
            height: 24,
            thickness: 0.3,
            color: appBorderColor(),
          ),
          _VideoComments(),
        ],
      ),
    );
  }
}

class _VideoDescription extends HookViewModelWidget<ExpandedMiniPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ExpandedMiniPlayerViewModel model) {
    List<TextSpan> linkifiedText = linkify(text: model.stream.description!.trim(), fontSize: 14);

    return RichText(
      text: TextSpan(
        children: linkifiedText,
      ),
    );
  }
}

class _VideoTags extends HookViewModelWidget<ExpandedMiniPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ExpandedMiniPlayerViewModel model) {
    return model.stream.tags == null || model.stream.tags!.isEmpty
        ? Container()
        : Container(
            margin: EdgeInsets.only(top: 8, bottom: 8),
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
}

class _VideoActions extends HookViewModelWidget<ExpandedMiniPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ExpandedMiniPlayerViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 32,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _VideoActionButton(
            icon: Icon(
              FontAwesomeIcons.heart,
              color: model.savedStream ? appActiveColor() : appIconColor(),
              size: 18,
            ),
            label: model.stream.savedBy == null ? "0" : model.stream.savedBy!.length.toString(),
            action: () => model.saveUnsaveStream(),
          ),
          _VideoActionButton(
            icon: Icon(
              FontAwesomeIcons.share,
              color: appIconColor(),
              size: 18,
            ),
            label: "Share",
            action: () => model.shareVideo(),
          ),
          // _VideoActionButton(
          //   icon: Icon(
          //     FontAwesomeIcons.download,
          //     color: appIconColor(),
          //     size: 18,
          //   ),
          //   label: "Download",
          //   action: () {},
          // ),
          _VideoActionButton(
            icon: Icon(
              FontAwesomeIcons.exclamationCircle,
              color: appIconColor(),
              size: 18,
            ),
            label: "Report",
            action: () => model.reportVideo(),
          ),
        ],
      ),
    );
  }
}

class _VideoActionButton extends StatelessWidget {
  final Icon icon;
  final String label;
  final VoidCallback action;

  _VideoActionButton({required this.icon, required this.label, required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: 6),
            CustomText(
              text: label,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: appFontColor(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoComments extends HookViewModelWidget<ExpandedMiniPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ExpandedMiniPlayerViewModel model) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: screenWidth(context),
      ),
      child: ListComments(
        refreshData: () async {},
        scrollController: null,
        showingReplies: false,
        pageStorageKey: model.commentStorageKey,
        refreshingData: false,
        results: model.commentResults,
        replyToComment: (val) => model.toggleReply(model.focusNode, val),
        deleteComment: (val) => model.showDeleteCommentConfirmation(context: context, comment: val),
      ),
    );
  }
}
