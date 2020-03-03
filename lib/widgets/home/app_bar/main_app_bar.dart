import 'package:flutter/material.dart';
import 'package:webblen/styles/custom_text.dart';
import 'package:webblen/widgets/common/images/round_pic.dart';
import 'package:webblen/widgets/notifications/notification_stream.dart';

class MainTabAppBar extends StatelessWidget {
  final String cityName;
  final String uid;
  final String userImageURL;
  final VoidCallback didPressUserImage;
  final VoidCallback didPressNotifBell;

  MainTabAppBar({
    this.cityName,
    this.uid,
    this.userImageURL,
    this.didPressUserImage,
    this.didPressNotifBell,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  context: context,
                  text: cityName,
                  textColor: Colors.black,
                  fontSize: cityName.length <= 6 ? 40 : cityName.length <= 8 ? 35 : cityName.length <= 10 ? 30 : cityName.length <= 12 ? 25 : 20,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                NotificationStream(
                  uid: uid,
                  onTap: didPressNotifBell,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: didPressUserImage,
                  child: RoundPic(
                    isUserPic: true,
                    picURL: userImageURL,
                    size: 50.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
