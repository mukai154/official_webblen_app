import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';

import '../custom_text.dart';

class ImageButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isOptional;
  final double height;
  final double width;
  ImageButton({@required this.onTap, @required this.isOptional, @required this.height, @required this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        color: appImageButtonColor(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.camera,
                color: appIconColorAlt(),
                size: 24,
              ),
              verticalSpaceTiny,
              CustomText(
                text: '1:1',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: appIconColorAlt(),
              ),
              verticalSpaceTiny,
              isOptional
                  ? CustomText(
                      text: '(optional)',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: appIconColorAlt(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePreviewButton extends StatelessWidget {
  final VoidCallback onTap;
  final File file;
  final String imgURL;
  final double height;
  final double width;

  ImagePreviewButton({@required this.onTap, @required this.file, @required this.imgURL, @required this.height, @required this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        child: file == null
            ? CachedNetworkImage(imageUrl: imgURL == null ? "" : imgURL, fit: BoxFit.contain, filterQuality: FilterQuality.medium)
            : Image.file(file, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
      ),
    );
  }
}
