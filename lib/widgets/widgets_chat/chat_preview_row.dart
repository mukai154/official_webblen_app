import 'package:flutter/material.dart';

import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time_calc.dart';

class ChatRowPreview extends StatelessWidget {
  final String chatName;
  final VoidCallback transitionToChat;
  final String lastMessageSent;
  final String lastMessageSentBy;
  final String lastMessageType;
  final int dateSent;
  final bool seenByUser;
  final TextStyle headerTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
    color: FlatColors.lightAmericanGray,
  );
  final TextStyle subHeaderTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: FlatColors.londonSquare,
  );
  final TextStyle bodyTextStyle = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    color: FlatColors.blackPearl,
  );
  final int numberOfUsersInChat;

  ChatRowPreview({
    this.chatName,
    this.seenByUser,
    this.transitionToChat,
    this.lastMessageSent,
    this.lastMessageSentBy,
    this.lastMessageType,
    this.dateSent,
    this.numberOfUsersInChat,
  });

  @override
  Widget build(BuildContext context) {
    final userCardContent = Container(
      padding: EdgeInsets.only(
        left: 8.0,
        top: 12.0,
        right: 14.0,
        bottom: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 8.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Fonts().textW700(
                    chatName,
                    24.0,
                    seenByUser ? FlatColors.darkGray : Colors.white,
                    TextAlign.left,
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 90,
                    ),
                    child: lastMessageType == "text"
                        ? Fonts().textW500(
                            lastMessageSentBy + ": " + lastMessageSent,
                            14.0,
                            seenByUser
                                ? FlatColors.lightAmericanGray
                                : Colors.white,
                            TextAlign.left)
                        : lastMessageType == "image"
                            ? Fonts().textW500(
                                lastMessageSentBy + ": Sent an Image",
                                14.0,
                                seenByUser
                                    ? FlatColors.lightAmericanGray
                                    : Colors.white,
                                TextAlign.left)
                            : Fonts().textW500(
                                lastMessageSentBy + "Sent a Video",
                                14.0,
                                seenByUser
                                    ? FlatColors.blackPearl
                                    : Colors.white,
                                TextAlign.left),
                  ),
                  SizedBox(
                    height: 6.0,
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: 8.0,
                ),
                child: numberOfUsersInChat > 2
                    ? numberOfUsersInChat == 3
                        ? Fonts().textW300(
                            "+ 1 other",
                            12.0,
                            seenByUser ? FlatColors.darkGray : Colors.white,
                            TextAlign.right,
                          )
                        : Fonts().textW300(
                            "+${numberOfUsersInChat - 1} others",
                            12.0,
                            seenByUser ? FlatColors.darkGray : Colors.white,
                            TextAlign.right,
                          )
                    : Container(),
              ),
              Fonts().textW300(
                TimeCalc().getPastTimeFromMilliseconds(dateSent),
                12.0,
                seenByUser ? FlatColors.darkGray : Colors.white,
                TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );

    final userCard = new Container(
      child: userCardContent,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: seenByUser
              ? [
                  Colors.white,
                  Colors.white,
                ]
              : [
                  FlatColors.webblenRed,
                  FlatColors.webblenPink,
                ],
        ),
      ),
    );

    return GestureDetector(
      onTap: transitionToChat,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 1.0,
        ),
        child: userCard,
      ),
    );
  }
}
