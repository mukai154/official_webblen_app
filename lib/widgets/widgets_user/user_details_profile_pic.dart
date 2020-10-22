import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/styles/flat_colors.dart';

class UserDetailsProfilePic extends StatelessWidget {
  final String userPicUrl;
  final double size;

  UserDetailsProfilePic({
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
    return UserDetailsProfilePic(
      userPicUrl: userImageURL,
      size: widget.size,
    );
  }
}

class UserProfilePicFromUsername extends StatefulWidget {
  final String username;
  final double size;

  UserProfilePicFromUsername({
    this.username,
    this.size,
  });

  @override
  _UserProfilePicFromUsernameState createState() => _UserProfilePicFromUsernameState();
}

class _UserProfilePicFromUsernameState extends State<UserProfilePicFromUsername> {
  String userImageURL = "";

  @override
  void initState() {
    super.initState();
    WebblenUserData().getUserImgByID(widget.username).then((url) {
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
    return UserDetailsProfilePic(
      userPicUrl: userImageURL,
      size: widget.size,
    );
  }
}
