import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';
import 'package:webblen/utils/custom_string_methods.dart';

import 'comment_text_field_view_model.dart';

class CommentTextFieldView extends StatelessWidget {
  final String contentID;
  final FocusNode focusNode;
  final bool isReplying;
  final String? replyReceiverUsername;
  final TextEditingController commentTextController;
  final Function(Map<String, dynamic>) onSubmitted;

  CommentTextFieldView({
    required this.contentID,
    required this.focusNode,
    required this.commentTextController,
    required this.isReplying,
    required this.replyReceiverUsername,
    required this.onSubmitted,
  });

  final AlgoliaSearchService? _algoliaSearchService = locator<AlgoliaSearchService>();

  Widget replyContainer() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 300,
      ),
      decoration: BoxDecoration(
        color: appBackgroundColor(),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: appBorderColorAlt(),
          width: 1.5,
        ),
      ),
      margin: EdgeInsets.only(left: 0.0, bottom: 8.0),
      padding: EdgeInsets.all(4.0),
      child: CustomText(
        text: 'Replying to @$replyReceiverUsername',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: appFontColor(),
      ),
    );
  }

  Widget commentTextField(BuildContext context, CommentTextFieldViewModel model) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: isReplying ? 130 : 80,
      ),
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              UserProfilePic(
                userPicUrl: model.user.profilePicURL,
                size: 45,
                isBusy: false,
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Container(
                  height: isReplying ? 100 : 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isReplying ? replyContainer() : Container(),
                      Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: isDarkMode() ? Colors.black87 : Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: TypeAheadField(
                          keepSuggestionsOnSuggestionSelected: true,
                          hideOnEmpty: false,
                          hideOnLoading: true,
                          suggestionsBoxDecoration: SuggestionsBoxDecoration(color: appBackgroundColor(), borderRadius: BorderRadius.all(Radius.circular(8))),
                          direction: AxisDirection.up,
                          textFieldConfiguration: TextFieldConfiguration(
                            onSubmitted: (val) {
                              List<WebblenUser> mentionedUsers = model.getMentionedUsers(commentText: val);
                              Map<String, dynamic> commentData = {
                                'comment': val,
                                'mentionedUsers': mentionedUsers,
                              };
                              return onSubmitted(commentData);
                            },
                            focusNode: focusNode,
                            textInputAction: TextInputAction.send,
                            minLines: 1,
                            maxLines: 5,
                            maxLengthEnforced: true,
                            enabled: true,
                            autocorrect: true,
                            controller: commentTextController,
                            textCapitalization: TextCapitalization.sentences,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(150),
                            ],
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Comment",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            autofocus: false,
                          ),
                          noItemsFoundBuilder: (context) {
                            return Container(height: 0, width: 0);
                          },
                          suggestionsCallback: (searchTerm) async {
                            int cursorPosition = commentTextController.selection.baseOffset;
                            String cursorString = searchTerm.substring(0, cursorPosition);
                            String lastWord = getLastWordInString(cursorString);
                            if (lastWord.startsWith("@") && lastWord.length > 1) {
                              return await _algoliaSearchService!.queryUsers(searchTerm: lastWord.substring(1, lastWord.length - 1), resultsLimit: 3);
                            }
                            return [];
                          },
                          itemBuilder: (context, user) {
                            if (user is WebblenUser) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                height: 50,
                                child: Row(
                                  children: [
                                    UserProfilePic(
                                      userPicUrl: user.profilePicURL,
                                      size: 35,
                                      isBusy: false,
                                    ),
                                    horizontalSpaceTiny,
                                    CustomText(
                                      text: "@${user.username}",
                                      fontSize: 16,
                                      textAlign: TextAlign.left,
                                      fontWeight: FontWeight.bold,
                                      color: appFontColor(),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container();
                          },
                          onSuggestionSelected: (user) {
                            if (user is WebblenUser) {
                              model.addUserToMentions(user);
                              focusNode.requestFocus();
                              int cursorPosition = commentTextController.selection.baseOffset;
                              String startOfString = commentTextController.text.substring(0, cursorPosition - 1);
                              String endOfString = commentTextController.text.substring(cursorPosition - 1, commentTextController.text.length - 1);
                              if (endOfString.length == 1) {
                                endOfString = "";
                              } else if (endOfString.length > 1) {
                                endOfString = endOfString.substring(2, endOfString.length - 1);
                              }
                              String modifiedStartOfString = replaceLastWordInString(startOfString, "@${user.username} ");

                              commentTextController.text = modifiedStartOfString + " " + endOfString;

                              commentTextController.selection = TextSelection.fromPosition(TextPosition(offset: modifiedStartOfString.length));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CommentTextFieldViewModel>.reactive(
      viewModelBuilder: () => CommentTextFieldViewModel(),
      builder: (context, model, child) => commentTextField(context, model),
    );
  }
}
