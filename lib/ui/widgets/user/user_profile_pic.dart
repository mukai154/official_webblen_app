import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';

class UserProfilePic extends StatelessWidget {
  final String? userPicUrl;
  final double? size;
  final bool? isBusy;
  final bool? hasBorder;

  UserProfilePic({
    this.hasBorder = false,
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
            decoration: BoxDecoration(color: CustomColors.iosOffWhite, borderRadius: BorderRadius.all(Radius.circular(size! / 2))),
          )
        : hasBorder!
            ? CircleAvatar(
                backgroundColor: appActiveColor(),
                radius: size! / 2 - 1,
                child: CircleAvatar(
                  radius: (size! / 2) - 3,
                  backgroundImage: NetworkImage(userPicUrl!),
                  backgroundColor: CustomColors.iosOffWhite,
                ),
              )
            : CircleAvatar(
                radius: size! / 2,
                backgroundImage: NetworkImage(userPicUrl!),
                backgroundColor: CustomColors.iosOffWhite,
              );
  }
}

class CurrentUserProfilePic extends StatelessWidget {
  final String userPicUrl;
  final double size;
  final bool isBusy;
  final VoidCallback editProfileAction;

  CurrentUserProfilePic({
    required this.userPicUrl,
    required this.size,
    required this.isBusy,
    required this.editProfileAction,
  });

  @override
  Widget build(BuildContext context) {
    return isBusy
        ? Container(
            height: size,
            width: size,
            decoration: BoxDecoration(color: CustomColors.iosOffWhite, borderRadius: BorderRadius.all(Radius.circular(size / 2))),
          )
        : GestureDetector(
            onTap: editProfileAction,
            child: Container(
              height: size,
              width: size,
              padding: EdgeInsets.all(4),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: size / 2,
                    backgroundImage: NetworkImage(userPicUrl),
                    backgroundColor: CustomColors.iosOffWhite,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: iconButtonBackgroundColor(),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 12,
                        color: appIconColor(),
                      ),
                    ),
                  ),
                ],
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
