import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:video_player/video_player.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/video_player/standard/standard_video_player_view_model.dart';
import 'package:webblen/ui/widgets/comments/comment_text_field/comment_text_field_view.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/custom_text_with_links.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/list_builders/list_comments/list_comments.dart';
import 'package:webblen/ui/widgets/tags/tag_button.dart';
import 'package:webblen/utils/time_calc.dart';

class StandardVideoPlayerView extends StatelessWidget {
  final String? id;
  StandardVideoPlayerView(@PathParam() this.id);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StandardVideoPlayerViewModel>.reactive(
      onModelReady: (model) => model.initialize(id!),
      viewModelBuilder: () => StandardVideoPlayerViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Video",
          showBackButton: true,
          onPressedBack: () => model.dismissVideoPlayer(),
        ),
        body: GestureDetector(
          onTap: () => model.unFocusKeyboard(context),
          child: Container(
            height: screenHeight(context),
            color: appBackgroundColor(),
            child: model.isBusy
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
                                      _CustomVideoPlayer(),
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

class _CustomVideoPlayer extends HookViewModelWidget<StandardVideoPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, StandardVideoPlayerViewModel model) {
    return SafeArea(
      child: Column(
        children: [
          Stack(
            children: [
              Column(
                children: [
                  !model.videoPlayerController!.value.isInitialized
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
                              onTap: () => model.pausePlayVideoPlayer(),
                              child: AspectRatio(
                                aspectRatio: model.videoPlayerController!.value.aspectRatio,
                                child: VideoPlayer(model.videoPlayerController!),
                              ),
                            ),
                            model.videoPlayerController!.value.isPlaying
                                ? Container()
                                : GestureDetector(
                                    onTap: () => model.pausePlayVideoPlayer(),
                                    child: AspectRatio(
                                      aspectRatio: model.videoPlayerController!.value.aspectRatio,
                                      child: model.videoPlayerController!.value.isPlaying
                                          ? Container()
                                          : Center(
                                              child: Icon(Icons.play_arrow, size: 30, color: Colors.white),
                                            ),
                                    ),
                                  ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: VideoProgressIndicator(
                                model.videoPlayerController!,
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

class _VideoInfo extends HookViewModelWidget<StandardVideoPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, StandardVideoPlayerViewModel model) {
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
                        text: "@${model.host!.username}",
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

class _VideoDescription extends HookViewModelWidget<StandardVideoPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, StandardVideoPlayerViewModel model) {
    List<TextSpan> linkifiedText = linkify(text: model.stream.description!.trim(), fontSize: 14);

    return RichText(
      text: TextSpan(
        children: linkifiedText,
      ),
    );
  }
}

class _VideoTags extends HookViewModelWidget<StandardVideoPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, StandardVideoPlayerViewModel model) {
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

class _VideoActions extends HookViewModelWidget<StandardVideoPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, StandardVideoPlayerViewModel model) {
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

class _VideoComments extends HookViewModelWidget<StandardVideoPlayerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, StandardVideoPlayerViewModel model) {
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
