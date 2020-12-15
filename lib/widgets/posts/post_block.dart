import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/utils/time_calc.dart';
import 'package:webblen/widgets/widgets_user/user_profile_pic.dart';

class PostImgBlock extends StatefulWidget {
  final String currentUID;
  final WebblenPost post;
  final VoidCallback viewPost;
  final VoidCallback viewUser;
  final VoidCallback viewParent;
  final bool showParentAction;
  final VoidCallback postOptions;

  PostImgBlock({
    this.currentUID,
    this.post,
    this.viewPost,
    this.viewUser,
    this.viewParent,
    this.showParentAction,
    this.postOptions,
  });

  @override
  _PostImgBlockState createState() => _PostImgBlockState();
}

class _PostImgBlockState extends State<PostImgBlock> {
  bool isLoading = true;
  String authorProfilePicURL;
  String authorUsername;

  @override
  void initState() {
    super.initState();
    WebblenUserData().getUserByID(widget.post.authorID).then((res) {
      authorProfilePicURL = res.profile_pic;
      authorUsername = res.username;
      isLoading = false;
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: widget.viewPost,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: widget.viewUser,
                    child: Row(
                      children: <Widget>[
                        isLoading
                            ? Shimmer.fromColors(
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                baseColor: CustomColors.iosOffWhite,
                                highlightColor: Colors.white,
                              )
                            : UserProfilePic(userPicUrl: authorProfilePicURL, size: 35),
                        SizedBox(
                          width: 10.0,
                        ),
                        isLoading
                            ? Container()
                            : widget.post.tags.isEmpty
                                ? Text(
                                    "@$authorUsername",
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "@$authorUsername",
                                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        widget.post.tags.toString().replaceAll("[", "").replaceAll("]", ""),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                      ],
                    ),
                  ),
                  widget.showParentAction != null && widget.showParentAction
                      ? Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: widget.viewParent,
                            child: Text(
                              'View Event',
                              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : widget.postOptions == null
                          ? Container()
                          : IconButton(
                              icon: Icon(Icons.more_horiz),
                              onPressed: widget.postOptions,
                            ),
                ],
              ),
            ),
            CachedNetworkImage(
              imageUrl: widget.post.imageURL,
              height: deviceSize.width,
              width: deviceSize.width,
              fadeInCurve: Curves.easeIn,
              filterQuality: FilterQuality.high,
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.comment,
                        size: 16,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        widget.post.commentCount.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    TimeCalc().getPastTimeFromMilliseconds(widget.post.postDateTimeInMilliseconds),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '$authorUsername ',
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: widget.post.body.trim(),
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Divider(
              thickness: 8.0,
              color: CustomColors.iosOffWhite,
            ),
          ],
        ),
      ),
    );
  }
}

class ShareablePostImgBlock extends StatelessWidget {
  final String username;
  final String profilePicURL;
  final WebblenPost post;
  final bool removeWebblenLogo;

  ShareablePostImgBlock({
    this.username,
    this.profilePicURL,
    this.post,
    this.removeWebblenLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    UserProfilePic(userPicUrl: profilePicURL, size: 35),
                    SizedBox(
                      width: 10.0,
                    ),
                    post.tags.isEmpty
                        ? Text(
                            "@$username",
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "@$username",
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                post.tags.toString().replaceAll("[", "").replaceAll("]", ""),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
                removeWebblenLogo
                    ? Container()
                    : Image.asset(
                        'assets/images/webblen_coin.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: post.imageURL,
                height: MediaQuery.of(context).size.width - 32,
                width: MediaQuery.of(context).size.width - 32,
                fadeInCurve: Curves.easeIn,
                filterQuality: FilterQuality.high,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '$username ',
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: post.body.trim(),
                    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostTextBlock extends StatefulWidget {
  final String currentUID;
  final WebblenPost post;
  final VoidCallback viewPost;
  final VoidCallback viewUser;
  final VoidCallback viewParent;
  final bool showParentAction;
  final VoidCallback postOptions;

  PostTextBlock({
    this.currentUID,
    this.post,
    this.viewPost,
    this.viewUser,
    this.viewParent,
    this.showParentAction,
    this.postOptions,
  });

  @override
  _PostTextBlockState createState() => _PostTextBlockState();
}

class _PostTextBlockState extends State<PostTextBlock> {
  bool isLoading = true;
  String authorProfilePicURL;
  String authorUsername;

  @override
  void initState() {
    super.initState();
    WebblenUserData().getUserByID(widget.post.authorID).then((res) {
      authorProfilePicURL = res.profile_pic;
      authorUsername = res.username;
      isLoading = false;
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.viewPost,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: widget.postOptions == null ? EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0) : EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: widget.viewUser,
                    child: Row(
                      children: <Widget>[
                        isLoading
                            ? Shimmer.fromColors(
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                baseColor: CustomColors.iosOffWhite,
                                highlightColor: Colors.white,
                              )
                            : UserProfilePic(userPicUrl: authorProfilePicURL, size: 35),
                        SizedBox(
                          width: 10.0,
                        ),
                        isLoading
                            ? Container()
                            : widget.post.tags.isEmpty
                                ? Text(
                                    "@$authorUsername",
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "@$authorUsername",
                                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        widget.post.tags.toString().replaceAll("[", "").replaceAll("]", ""),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                      ],
                    ),
                  ),
                  widget.showParentAction != null && widget.showParentAction
                      ? Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: widget.viewParent,
                            child: Text(
                              'View Event',
                              style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : widget.postOptions == null
                          ? Container()
                          : IconButton(
                              icon: Icon(Icons.more_horiz),
                              onPressed: widget.postOptions,
                            ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.post.body,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.comment,
                        size: 16,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        widget.post.commentCount.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    TimeCalc().getPastTimeFromMilliseconds(widget.post.postDateTimeInMilliseconds),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            Divider(
              thickness: 8.0,
              color: CustomColors.iosOffWhite,
            ),
          ],
        ),
      ),
    );
  }
}

class ShareablePostTextBlock extends StatelessWidget {
  final String username;
  final String profilePicURL;
  final WebblenPost post;
  final bool removeWebblenLogo;

  ShareablePostTextBlock({
    this.username,
    this.profilePicURL,
    this.post,
    this.removeWebblenLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    UserProfilePic(userPicUrl: profilePicURL, size: 35),
                    SizedBox(
                      width: 10.0,
                    ),
                    post.tags.isEmpty
                        ? Text(
                            "@$username",
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "@$username",
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                post.tags.toString().replaceAll("[", "").replaceAll("]", ""),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
                removeWebblenLogo
                    ? Container()
                    : Image.asset(
                        'assets/images/webblen_coin.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              post.body,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
