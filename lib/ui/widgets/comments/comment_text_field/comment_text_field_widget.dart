import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/user_widgets/user_profile_pic.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

import 'comment_text_field_model.dart';

class CommentTextFieldWidget extends StatelessWidget {
  final FocusNode focusNode;
  final bool isReplying;
  final String replyReceiverUsername;
  final TextEditingController commentTextController;
  final Function(String) onSubmitted;

  CommentTextFieldWidget({
    @required this.focusNode,
    @required this.commentTextController,
    @required this.isReplying,
    @required this.replyReceiverUsername,
    @required this.onSubmitted,
  });

  Widget replyContainer() {
    return Container(
      decoration: BoxDecoration(
        color: appBackgroundColor(),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: appBorderColorAlt(),
          width: 1.5,
        ),
      ),
      margin: EdgeInsets.only(left: 8.0, bottom: 8.0),
      padding: EdgeInsets.all(4.0),
      child: CustomText(
        text: 'Replying to @$replyReceiverUsername',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: appFontColor(),
      ),
    );
  }

  Widget commentTextField(BuildContext context, CommentTextFieldModel model) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 32,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            isDarkMode() ? Colors.black45 : Colors.white,
            isDarkMode() ? Colors.black26 : Colors.white54,
            isDarkMode() ? Colors.black12 : Colors.white12,
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          UserProfilePic(
            userPicUrl: model.currentUserProfilePicURL,
            size: 45,
            isBusy: false,
          ),
          Container(
            height: isReplying ? 80 : 50,
            width: MediaQuery.of(context).size.width - 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isReplying ? replyContainer() : Container(),
                Container(
                  height: 40,
                  margin: EdgeInsets.only(left: 8.0),
                  padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: TextField(
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 5,
                    maxLengthEnforced: true,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) => onSubmitted(val),
                    style: TextStyle(color: Colors.white),
                    controller: commentTextController, //messageFieldController,
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(150),
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Comment',
                      hintStyle: TextStyle(
                        color: Colors.white30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CommentTextFieldModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => CommentTextFieldModel(),
      builder: (context, model, child) => model.isBusy || model.errorDetails != null ? Container() : commentTextField(context, model),
    );
  }
}
