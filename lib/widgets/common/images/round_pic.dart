import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webblen/styles/flat_colors.dart';

class RoundPic extends StatelessWidget {
  final String picURL;
  final double size;
  final bool isUserPic;

  RoundPic({
    this.picURL,
    this.size,
    this.isUserPic,
  });

  @override
  Widget build(BuildContext context) {
    return picURL == null
        ? Container()
        : Container(
            height: size,
            width: size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: picURL,
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
                  isUserPic ? FontAwesomeIcons.user : FontAwesomeIcons.question,
                  color: Colors.black12,
                ),
                useOldImageOnUrlChange: false,
              ),
            ),
          );
  }
}
