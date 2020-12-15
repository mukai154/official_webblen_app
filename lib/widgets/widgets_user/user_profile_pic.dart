import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/styles/flat_colors.dart';

class UserProfilePic extends StatelessWidget {
  final String userPicUrl;
  final double size;

  UserProfilePic({
    this.userPicUrl,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: userPicUrl,
          filterQuality: FilterQuality.medium,
          placeholder: (context, url) => Container(
            height: size,
            width: size,
            child: Shimmer.fromColors(
                baseColor: FlatColors.clouds,
                highlightColor: Colors.white,
                child: Container(
                  height: size,
                  width: size,
                  color: Colors.white,
                )),
          ),
          errorWidget: (
            context,
            url,
            error,
          ) =>
              Icon(
            FontAwesomeIcons.user,
            color: Colors.black12,
          ),
          useOldImageOnUrlChange: false,
        ),
      ),
    );
  }
}

class UserProfilePicFromUID extends StatefulWidget {
  final String uid;
  final double size;

  UserProfilePicFromUID({
    this.uid,
    this.size,
  });

  @override
  _UserProfilePicFromUIDState createState() => _UserProfilePicFromUIDState();
}

class _UserProfilePicFromUIDState extends State<UserProfilePicFromUID> {
  String userImageURL = "";

  @override
  void initState() {
    super.initState();
    WebblenUserData().getUserImgByID(widget.uid).then((url) {
      if (url != null) {
        userImageURL = url;
        if (this.mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserProfilePic(
      userPicUrl: userImageURL,
      size: widget.size,
    );
  }
}
