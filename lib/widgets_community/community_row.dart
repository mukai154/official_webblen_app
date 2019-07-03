import 'package:flutter/material.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_user/user_details_profile_pic.dart';


class CommunityRow extends StatefulWidget {

  final Community community;
  final VoidCallback onClickAction;
  final bool showAreaName;
  CommunityRow({this.community, this.onClickAction, this.showAreaName});
  @override
  _CommunityRowState createState() => _CommunityRowState();
}

class _CommunityRowState extends State<CommunityRow> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    List members = widget.community.memberIDs.toList()..shuffle();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: ([
              BoxShadow(
                color: Colors.black12,
                blurRadius: 1.8,
                spreadRadius: 0.5,
                offset: Offset(0.0, 3.0),
              ),
            ])
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          // Do onTap() if it isn't null, otherwise do print()
          onTap: widget.onClickAction,
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Fonts().textW700(widget.community.name, 20.0, Colors.black, TextAlign.left),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Fonts().textW400('${widget.community.memberIDs.length} Active Members', 12.0, FlatColors.lightAmericanGray, TextAlign.left),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Fonts().textW400('${widget.community.followers.length} Followers', 12.0, FlatColors.lightAmericanGray, TextAlign.left),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    widget.community.status == 'active'
                        ? Container(
                      width: 125.0,
                      child: Stack(
                        children: <Widget>[
                          UserProfilePicFromUID(uid: members[0], size: 55.0),
                          Positioned(
                            left: 30.0,
                            child: members[1] == null ? Container() : UserProfilePicFromUID(uid: members[1], size: 55.0),
                          ),
                          Positioned(
                            left: 60.0,
                            child: members[2] == null ? Container() : UserProfilePicFromUID(uid: members[2], size: 55.0),
                          )

                        ],
                      ),
                    )
                        : Container(),
                    widget.showAreaName
                        ? Padding(
                      padding: EdgeInsets.only(right: 16.0, top: 4.0),
                      child: Fonts().textW300(widget.community.areaName, 16, FlatColors.darkGray, TextAlign.right),
                    )
                        : Container()
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
