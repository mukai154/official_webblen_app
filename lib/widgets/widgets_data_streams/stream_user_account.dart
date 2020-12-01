import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/widgets/widgets_user/user_profile_pic.dart';

class StreamUserAccount extends StatelessWidget {
  final String uid;
  final bool isLoading;
  final bool useBorderColor;

  StreamUserAccount({
    this.uid,
    this.isLoading,
    this.useBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            ),
            baseColor: CustomColors.iosOffWhite,
            highlightColor: Colors.white)
        : StreamBuilder(
            stream: FirebaseFirestore.instance.collection("webblen_user").doc(uid).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
              if (!userSnapshot.hasData)
                return Shimmer.fromColors(
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    ),
                    baseColor: CustomColors.iosOffWhite,
                    highlightColor: Colors.white);
              var userData = userSnapshot.data.data();
              return userData['d']['profile_pic'] != null
                  ? Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: useBorderColor ? CustomColors.webblenRed : CustomColors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16.5)),
                      ),
                      child: Center(
                        child: UserProfilePic(
                          userPicUrl: userData['d']["profile_pic"],
                          size: 32.0,
                        ),
                      ),
                    )
                  : Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: useBorderColor ? CustomColors.webblenRed : CustomColors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16.5)),
                      ),
                      child: Center(
                        child: UserProfilePic(
                          userPicUrl: '',
                          size: 32.0,
                        ),
                      ),
                    );
//                StreamBuilder(
//                stream: Firestore.instance
//                    .collection("chats")
//                    .where(
//                      'users',
//                      arrayContains: uid,
//                    )
//                    .snapshots(),
//                builder: (context, AsyncSnapshot<QuerySnapshot> userChats) {
//                  if (!userChats.hasData) return Container();
//                  bool hasMessages = false;
//                  userChats.data.documents.forEach((chatDoc) {
//                    List seenBy = chatDoc.data['seenBy'];
//                    if (!seenBy.contains(uid) && chatDoc.data['isActive']) {
//                      hasMessages = true;
//                      return;
//                    }
//                  });
//                  return userData['d']['profile_pic'] != null
//                      ? UserDetailsProfilePic(
//                          userPicUrl: userData['d']["profile_pic"],
//                          size: 35.0,
//                        )
//                      : UserDetailsProfilePic(
//                          userPicUrl: '',
//                          size: 35.0,
//                        );
//                },
//              );
            },
          );
  }
}
