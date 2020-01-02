import 'package:flutter/material.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'dart:math';


class CommunityRow extends StatefulWidget {

  final Community community;
  final VoidCallback onClickAction;
  final bool showAreaName;
  CommunityRow({this.community, this.onClickAction, this.showAreaName});
  @override
  _CommunityRowState createState() => _CommunityRowState();
}

class _CommunityRowState extends State<CommunityRow> with AutomaticKeepAliveClientMixin {

  String comImage = 'https://digitalsynopsis.com/wp-content/uploads/2017/02/beautiful-color-gradients-backgrounds-018-cloudy-knoxville.png';

  @override
  void initState() {
    super.initState();
    CommunityDataService().getCommunityImageURL(widget.community.areaName, widget.community.name).then((res){
      if (res != null){
        comImage = res;
      } else {
        int ranNum = Random().nextInt(5);
        if (ranNum == 0){
          comImage = 'https://i.ibb.co/hCwqSkj/undraw-energizer-2224.png';
        } else if (ranNum == 1){
          comImage = 'https://i.ibb.co/fMmL9ZF/undraw-ice-cream-s2rh.png';
        } else if (ranNum == 2){
          comImage = 'https://i.ibb.co/sQvypFr/undraw-welcoming-xvuq.png';
        } else if (ranNum == 3){
          comImage = 'https://i.ibb.co/V9zHrBV/undraw-imagination-ok71.png';
        } else {
          comImage = 'https://i.ibb.co/F6CRsHq/undraw-sunlight-tn7t.png';
        }
      }
      if (this.mounted){
        setState(() {});
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        height: 90.0,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.0),
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
          borderRadius: BorderRadius.circular(18.0),
          // Do onTap() if it isn't null, otherwise do print()
          onTap: widget.onClickAction,
          child: Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Fonts().textW700(widget.community.name, 22.0, Colors.black, TextAlign.left),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          child:  Fonts().textW400('${widget.community.memberIDs.length} Members', 15.0, FlatColors.lightAmericanGray, TextAlign.left),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    widget.community.status == 'active'
                        ? Container(
                      width: (MediaQuery.of(context).size.width - 16) / 2.5,
                      child: Stack(
                            children: <Widget>[
                              comImage == null
                              ? Container()
                              : ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18.0),
                                  bottomRight: Radius.circular(18.0),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: comImage,
                                  width: (MediaQuery.of(context).size.width - 16) / 2.5,
                                  height: 90.0,
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment.center,
                                ),
                              ),
                              Container(
                                height: 90.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(18.0),
                                    bottomRight: Radius.circular(18.0)
                                  ),
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.white10],
                                    begin: Alignment(-1.0, 0),
                                    end: Alignment(-0.6, 0)
                                  )
                                ),
                              ),
                              Container(
                                height: 90.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(18.0),
                                        bottomRight: Radius.circular(18.0)
                                    ),
                                    gradient: LinearGradient(
                                        colors: [Colors.white, Colors.white10],
                                        begin: Alignment(-0.5, 1),
                                        end: Alignment(0.4, -0.10)
                                    )
                                ),
                              ),
                              widget.showAreaName
                                  ? Align(
                                    alignment: Alignment(0.85, 0),
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 65.0),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(24.0),
                                        color: FlatColors.textFieldGray,
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
                                            child: Fonts().textW300(widget.community.areaName, 12.0, Colors.black, TextAlign.center)
                                        ),
                                      ),
                                    )
                                  )
                                  : Container()
//                              UserProfilePicFromUID(uid: members[0], size: 55.0),
//                              Positioned(
//                                left: 30.0,
//                                child: members[1] == null ? Container() : UserProfilePicFromUID(uid: members[1], size: 55.0),
//                              ),
//                              Positioned(
//                                left: 60.0,
//                                child: members[2] == null ? Container() : UserProfilePicFromUID(uid: members[2], size: 55.0),
//                              )
                            ],
                      ),
                    )
                        : Container(),

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

class AreaRow extends StatelessWidget {

  final String areaName;
  final int numberOfCommunities;
  final VoidCallback onTapAction;
  AreaRow({this.areaName, this.numberOfCommunities, this.onTapAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        height: 90.0,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.0),
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
          borderRadius: BorderRadius.circular(18.0),
          onTap: onTapAction,
          child: Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Fonts().textW700(areaName, 22.0, Colors.black, TextAlign.left),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          child:  Fonts().textW400('$numberOfCommunities Communities', 15.0, FlatColors.lightAmericanGray, TextAlign.left),
                        ),
                      ],
                    ),
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


