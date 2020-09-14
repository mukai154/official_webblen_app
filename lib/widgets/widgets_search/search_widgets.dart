import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/truncate_text.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';

class SearchResultRow extends StatelessWidget {
  final Map<String, dynamic> resultData;
  final VoidCallback tapAction;
  final VoidCallback addFriendAction;

  SearchResultRow({
    this.resultData,
    this.tapAction,
    this.addFriendAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapAction,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 4.0,
        ),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      resultData['imageData'] == null || resultData['imageData'] == ''
                          ? Container()
                          : UserDetailsProfilePic(
                              userPicUrl: resultData['imageData'],
                              size: 50.0,
                            ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TruncText(
                              containerWidth: MediaQuery.of(context).size.width * 0.7,
                              text: resultData['resultHeader'],
                              textSize: 16.0,
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Fonts().textW300(
                              resultData['resultType'],
                              14.0,
                              Colors.black,
                              TextAlign.left,
                            ),
                          ],
                        ),
                      ],
                    ),
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
