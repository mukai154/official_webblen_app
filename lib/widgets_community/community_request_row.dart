import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:webblen/widgets_data_streams/stream_comment_data.dart';
import 'package:webblen/models/community_request.dart';

class CommunityRequestRow extends StatelessWidget {

  final CommunityRequest request;
  final VoidCallback upVoteAction;
  final VoidCallback downVoteAction;
  final VoidCallback transitionToComRequestDetails;
  final String uid;
  CommunityRequestRow({this.request, this.transitionToComRequestDetails, this.upVoteAction, this.downVoteAction, this.uid});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4.0),
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: GestureDetector(
          onTap: transitionToComRequestDetails,
          child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 16.0, top: 12.0, right: 8.0),
                      constraints: BoxConstraints(
                          maxWidth: 400
                      ),
                      child: Fonts().textW700(request.requestTitle, 24.0, Colors.black, TextAlign.start),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start ,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 16.0, top: 2.0, right: 8.0),
                      width: MediaQuery.of(context).size.width * 0.96,
                      child: Fonts().textW400('${request.requestExplanation}', 14.0, Colors.black, TextAlign.left),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                          child: Material(
                            borderRadius: BorderRadius.circular(8.0),
                            color: FlatColors.textFieldGray,
                            child: Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Fonts().textW400('${request.requestType == 'app' ? 'Webblen' : request.requestType}', 12.0, Colors.black, TextAlign.center)
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          child: GestureDetector(
                            onTap: upVoteAction,
                            child: Row(
                              children: <Widget>[
                                Fonts().textW500('${request.upVotes.length}', 16.0, request.upVotes.contains(uid) ? FlatColors.greenTeal : Colors.grey, TextAlign.right),
                                SizedBox(width: 6.0),
                                Icon(FontAwesomeIcons.solidArrowAltCircleUp, color: request.upVotes.contains(uid) ? FlatColors.greenTeal : Colors.grey, size: 18.0),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Container(
                          child: GestureDetector(
                            onTap: downVoteAction,
                            child: Row(
                              children: <Widget>[
                                Fonts().textW500('${request.downVotes.length}', 16.0,request.downVotes.contains(uid) ? Colors.red : Colors.grey, TextAlign.right),
                                SizedBox(width: 6.0),
                                Icon(FontAwesomeIcons.solidArrowAltCircleDown, color: request.downVotes.contains(uid) ? Colors.red : Colors.grey, size: 18.0),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
//                        Container(
//                          child: GestureDetector(
//                            onTap: transitionToComRequestDetails,
//                            child: Row(
//                              children: <Widget>[
//                                StreamRequestCommentCountData(requestID: request.requestID),
//                                SizedBox(width: 6.0),
//                                Icon(FontAwesomeIcons.comment, color: Colors.black, size: 18.0),
//                              ],
//                            ),
//                          ),
//                        ),
//                        SizedBox(width: 16.0),
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
