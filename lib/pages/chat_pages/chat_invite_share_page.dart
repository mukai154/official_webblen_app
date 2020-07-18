import 'package:flutter/material.dart';
import 'package:webblen/firebase_data/chat_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/pages/chat_pages/chat_page.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_flushbar.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_user/user_row.dart';

class ChatInviteSharePage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenEvent event;

  ChatInviteSharePage({
    this.currentUser,
    this.event,
  });

  @override
  State<StatefulWidget> createState() {
    return _ChatInviteSharePageState();
  }
}

class _ChatInviteSharePageState extends State<ChatInviteSharePage> {
  bool isLoading = true;
  List<WebblenUser> searchResults = [];
  List<WebblenUser> friends = [];
  List<String> invitedUsers = [];

  void validateAndSubmit() {
    if (invitedUsers.isEmpty) {
      AlertFlushbar(headerText: "Error", bodyText: "Choose Someone to Message").showAlertFlushbar(context);
    } else {
      ShowAlertDialogService().showLoadingDialog(context);
      if (!invitedUsers.contains(widget.currentUser.uid)) {
        invitedUsers.add(widget.currentUser.uid);
      }
      if (widget.event == null) {
        startNewChat();
      } else {
        shareEvent();
      }
    }
  }

  void startNewChat() {
    ChatDataService().checkIfChatExists(invitedUsers).then((chatKey) {
      if (chatKey == null) {
        ChatDataService().createChat(widget.currentUser.uid, invitedUsers).then((res) {
          if (res != null && res != 'error') {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  currentUser: widget.currentUser,
                  chatKey: res,
                ),
              ),
            );
          } else {
            Navigator.of(context).pop();
          }
        });
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              currentUser: widget.currentUser,
              chatKey: chatKey,
            ),
          ),
        );
      }
    });
  }

  void shareEvent() {
    ChatDataService().checkIfChatExists(invitedUsers).then((chatKey) {
      if (chatKey == null) {
        ChatDataService().createChat(widget.currentUser.uid, invitedUsers).then((res) {
          if (res != null && res != 'error') {
            ChatDataService()
                .sendMessage(
              res,
              widget.currentUser.username,
              widget.currentUser.uid,
              DateTime.now().millisecondsSinceEpoch,
              widget.event.id,
              "eventShare",
            )
                .then((error) {
              if (error.isEmpty) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      currentUser: widget.currentUser,
                      chatKey: res,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pop();
                ShowAlertDialogService().showFailureDialog(
                  context,
                  "Uh Oh! 😬",
                  "There was an issue sharing this event. Please Try Again Later.",
                );
              }
            });
          } else {
            Navigator.of(context).pop();
            ShowAlertDialogService().showFailureDialog(
              context,
              "Uh Oh! 😬",
              "There was an issue sharing this event. Please Try Again Later.",
            );
          }
        });
      } else {
        ChatDataService()
            .sendMessage(
          chatKey,
          widget.currentUser.username,
          widget.currentUser.uid,
          DateTime.now().millisecondsSinceEpoch,
          widget.event.id,
          "eventShare",
        )
            .then((error) {
          if (error.isEmpty) {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  currentUser: widget.currentUser,
                  chatKey: chatKey,
                ),
              ),
            );
          } else {
            Navigator.of(context).pop();
            ShowAlertDialogService().showFailureDialog(
              context,
              "Uh Oh! 😬",
              "There was an issue sharing this event. Please Try Again Later.",
            );
          }
        });
      }
    });
  }

  void initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        searchResults = friends;
      });
    } else {
      searchResults = friends
          .where(
            (user) => user.username.contains(
              value.toLowerCase(),
            ),
          )
          .toList();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentUser.friends != null || widget.currentUser.friends.isNotEmpty) {
      UserDataService().getUsersFromList(widget.currentUser.friends).then((result) {
        if (result != null && result.isNotEmpty) {
          friends = result;
          friends.sort(
            (userA, userB) => userA.username.compareTo(userB.username),
          );
          isLoading = false;
          setState(() {});
        }
      });
    } else {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        widget.event == null ? "New Chat" : "Share Event",
        GestureDetector(
          onTap: () => validateAndSubmit(),
          child: Padding(
            padding: EdgeInsets.only(
              top: 18.0,
              right: 16.0,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
              child: Fonts().textW500(
                widget.event == null ? "Create" : "Share",
                18.0,
                FlatColors.darkGray,
                TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: isLoading
            ? LoadingScreen(
                context: context,
                loadingDescription: 'Loading Friends...',
              )
            : ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  String friendUid = friends[index].uid;
                  return UserRowInvite(
                    user: friends[index],
                    onTap: () {
                      if (invitedUsers.contains(friendUid)) {
                        invitedUsers.remove(friendUid);
                      } else {
                        invitedUsers.add(friendUid);
                      }
                      setState(() {});
                    },
                    didInvite: invitedUsers.contains(friends[index].uid),
                  );
                },
              ),
      ),
    );
  }
}
