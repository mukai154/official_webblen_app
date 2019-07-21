import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/widgets_user/user_details_profile_pic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/widgets_common/common_progress.dart';

class StreamUserAccount extends StatelessWidget {

  final String uid;
  final VoidCallback accountAction;

  StreamUserAccount({this.uid, this.accountAction});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection("users").document(uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return CustomCircleProgress(20.0, 20.0, 20.0, 20.0, Colors.black38);
          var userData = userSnapshot.data;
          return StreamBuilder(
            stream: Firestore.instance.collection("chats").where('users', arrayContains: uid).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> userChats){
              if (!userChats.hasData) return Container();
              bool hasMessages = false;
              userChats.data.documents.forEach((chatDoc){
                List seenBy = chatDoc.data['seenBy'];
                if (!seenBy.contains(uid) && chatDoc.data['isActive']){
                  hasMessages = true;
                  return;
                }
              });
              return Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: InkWell(
                        onTap: accountAction,
                        child: Hero(
                            tag: 'user-profile-pic-dashboard',
                            child: userData['profile_pic'] != null
                                ? Stack(
                              children: <Widget>[
                                UserDetailsProfilePic(userPicUrl:  userData["profile_pic"], size: 45.0),
                                hasMessages
                                    ? Container(
                                  alignment: Alignment(1, -1),
                                  child: Icon(FontAwesomeIcons.solidCircle, color: Colors.redAccent, size: 12.0),
                                )
                                    : Container(),
                              ],
                            )
                              : UserDetailsProfilePic(userPicUrl: '', size: 45.0),
                        ),
                      )
                  );//
            },
          );
        });
  }
}
