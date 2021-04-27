import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webblen/constants/app_colors.dart';

class UserProfilePic extends StatelessWidget {
  final String? userPicUrl;
  final double? size;
  final bool? isBusy;

  UserProfilePic({
    this.userPicUrl,
    this.size,
    this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    return isBusy!
        ? Container(
            height: size,
            width: size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size! / 2),
              child: Container(
                height: size,
                width: size,
                child: Shimmer.fromColors(
                  baseColor: appShimmerBaseColor(),
                  highlightColor: appShimmerHighlightColor(),
                  child: Container(
                    height: size,
                    width: size,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        : Container(
            height: size,
            width: size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size! / 2),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: userPicUrl!,
                filterQuality: FilterQuality.medium,
                placeholder: (context, url) => Container(
                  height: size,
                  width: size,
                  child: Shimmer.fromColors(
                      baseColor: appShimmerBaseColor(),
                      highlightColor: appShimmerHighlightColor(),
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
                  color: appFontColor(),
                ),
                useOldImageOnUrlChange: false,
              ),
            ),
          );
  }
}

class UserProfilePicFromFile extends StatelessWidget {
  final File? file;
  final double? size;

  UserProfilePicFromFile({
    this.file,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size! / 2),
        child: Container(
          height: size,
          width: size,
          child: Image.file(
            file!,
            filterQuality: FilterQuality.medium,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
