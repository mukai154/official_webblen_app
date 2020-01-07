import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/send_invite.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_user/stats_event_history_count.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';
import 'package:webblen/widgets/widgets_wallet/wallet_attendance_power_bar.dart';
import 'package:webblen/widgets/widgets_webblen/webblen_coin.dart';

class UserDrawerMenu {
  final BuildContext context;
  final WebblenUser currentUser;

  UserDrawerMenu({
    this.context,
    this.currentUser,
  });

  final ContactPicker _contactPicker = new ContactPicker();

  Widget menuRow(
      Icon icon, String optionName, Color optionColor, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        constraints: BoxConstraints(
          maxHeight: 40.0,
          maxWidth: 200.0,
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 8.0,
                right: 16.0,
                top: 4.0,
                bottom: 4.0,
              ),
              child: icon,
            ),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
              child: Fonts().textW400(
                optionName,
                16.0,
                optionColor,
                TextAlign.left,
              ),
            ),
          ],
        ),
      ),
      dense: true,
      onTap: onTap,
    );
  }

  Widget buildUserDrawerMenu() {
    return Drawer(
      child: currentUser == null
          ? ListView()
          : ListView(
              children: <Widget>[
                DrawerHeader(
                  child: currentUser == null
                      ? CustomCircleProgress(
                          30.0,
                          30.0,
                          30.0,
                          30.0,
                          FlatColors.darkGray,
                        )
                      : Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                left: 6.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  currentUser.profile_pic != null
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            PageTransitionService(
                                              context: context,
                                              currentUser: currentUser,
                                            ).transitionToCurrentUserDetailsPage();
                                          },
                                          child: UserDetailsProfilePic(
                                            userPicUrl: currentUser.profile_pic,
                                            size: 70.0,
                                          ),
                                        )
                                      : CustomCircleProgress(
                                          20.0,
                                          20.0,
                                          10.0,
                                          10.0,
                                          FlatColors.londonSquare,
                                        ),
                                  IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.qrcode,
                                      color: Colors.black,
                                      size: 24.0,
                                    ),
                                    onPressed: () {
                                      ShowAlertDialogService()
                                          .showAccountQRDialog(
                                              context,
                                              currentUser.username,
                                              currentUser.uid,
                                              () => PageTransitionService(
                                                    context: context,
                                                    currentUser: currentUser,
                                                  ).openWebblenScanner());
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 8.0,
                                top: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      PageTransitionService(
                                        context: context,
                                        currentUser: currentUser,
                                      ).transitionToCurrentUserDetailsPage();
                                    },
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        textScaleFactor: 1.0,
                                      ),
                                      child: Fonts().textW700(
                                        '@' + currentUser.username,
                                        20.0,
                                        Colors.black,
                                        TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 6.0,
                                top: 6.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  MiniAttendancePowerBar(
                                    currentAP: currentUser.ap,
                                    apLvl: currentUser.apLvl,
                                  ),
                                  Container(
                                    width: 18.0,
                                  ),
                                  StatsEventHistoryCount(
                                    eventHistoryCount: currentUser
                                        .eventHistory.length
                                        .toString(),
                                    textColor: Colors.black,
                                    textSize: 14.0,
                                    iconSize: 20.0,
                                    onTap: () {
                                      Navigator.pop(context);
                                      PageTransitionService(
                                        context: context,
                                        currentUser: currentUser,
                                      ).transitionToCurrentUserDetailsPage();
                                    },
                                  ),
                                  Container(
                                    width: 18.0,
                                  ),
                                  ShowAmountOfWebblen(
                                    amount: currentUser.eventPoints
                                        .toStringAsFixed(2),
                                    textColor: Colors.black,
                                    textSize: 14.0,
                                    iconSize: 24.0,
                                    onTap: null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                menuRow(
                  Icon(
                    FontAwesomeIcons.userFriends,
                    color: FlatColors.blackPearl,
                    size: 18.0,
                  ),
                  'Friends',
                  FlatColors.blackPearl,
                  () {
                    Navigator.pop(context);
                    PageTransitionService(
                      context: context,
                      uid: currentUser.uid,
                    ).transitionToFriendsPage();
                  },
                ),
                ListTile(
                  leading: Container(
                    constraints: BoxConstraints(
                      maxHeight: 40.0,
                      maxWidth: 200.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 8.0,
                        ),
                        Icon(
                          FontAwesomeIcons.envelope,
                          color: FlatColors.blackPearl,
                          size: 18.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaleFactor: 1.0,
                          ),
                          child: Fonts().textW400(
                            'Messages',
                            16.0,
                            FlatColors.blackPearl,
                            TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          width: 6.0,
                        ),
                        StreamBuilder(
                          stream: Firestore.instance
                              .collection("chats")
                              .where(
                                'users',
                                arrayContains: currentUser.uid,
                              )
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot> userChats) {
                            if (!userChats.hasData) return Container();
                            Widget hasMessagesWidget = Container();
                            userChats.data.documents.forEach((chatDoc) {
                              List seenBy = chatDoc.data['seenBy'];
                              if (!seenBy.contains(currentUser.uid) &&
                                  chatDoc.data['isActive']) {
                                hasMessagesWidget = Icon(
                                  FontAwesomeIcons.solidCircle,
                                  color: FlatColors.webblenRed,
                                  size: 10.0,
                                );
                                return;
                              }
                            });
                            return hasMessagesWidget;
                          },
                        ),
                      ],
                    ),
                  ),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context);
                    PageTransitionService(
                      context: context,
                      currentUser: currentUser,
                    ).transitionToChatIndexPage();
                  },
                ),
                menuRow(
                  Icon(
                    FontAwesomeIcons.calendar,
                    color: FlatColors.blackPearl,
                    size: 18.0,
                  ),
                  'Calendar',
                  FlatColors.blackPearl,
                  () {
                    Navigator.pop(context);
                    PageTransitionService(
                      context: context,
                      currentUser: currentUser,
                    ).transitionToCalendarPage();
                  },
                ),
                menuRow(
                  Icon(
                    FontAwesomeIcons.store,
                    color: FlatColors.blackPearl,
                    size: 18.0,
                  ),
                  'Shop',
                  FlatColors.blackPearl,
                  () {
                    Navigator.pop(context);
                    PageTransitionService(
                      context: context,
                      currentUser: currentUser,
                    ).transitionToShopPage();
                  },
                ),
                Container(
                  height: 12.0,
                ),
                Divider(
                  height: 1.0,
                  color: Colors.black12,
                ),
                currentUser.canMakeAds
                    ? menuRow(
                        Icon(
                          FontAwesomeIcons.ad,
                          color: FlatColors.blackPearl,
                          size: 18.0,
                        ),
                        'Create Ad',
                        FlatColors.blackPearl,
                        () {
                          Navigator.pop(context);
                          PageTransitionService(
                            context: context,
                            currentUser: currentUser,
                          ).transitionToCreateAdPage();
                        },
                      )
                    : Container(),
                menuRow(
                  Icon(
                    FontAwesomeIcons.cog,
                    color: FlatColors.blackPearl,
                    size: 18.0,
                  ),
                  'Settings',
                  FlatColors.blackPearl,
                  () {
                    Navigator.pop(context);
                    PageTransitionService(
                      context: context,
                      currentUser: currentUser,
                    ).transitionToSettingsPage();
                  },
                ),
                menuRow(
                  Icon(
                    FontAwesomeIcons.comments,
                    color: FlatColors.blackPearl,
                    size: 18.0,
                  ),
                  'Invite Friends',
                  FlatColors.blackPearl,
                  () async {
                    Contact contact = await _contactPicker.selectContact();
                    SendInviteMessage().sendSMS(
                      'test message',
                      [contact.phoneNumber.number],
                    );
                  },
                ),
                currentUser != null && currentUser.isCommunityBuilder
                    ? menuRow(
                        Icon(
                          FontAwesomeIcons.trophy,
                          color: FlatColors.blackPearl,
                          size: 18.0,
                        ),
                        'Create Reward',
                        FlatColors.blackPearl,
                        () {
                          Navigator.pop(context);
                          PageTransitionService(
                            context: context,
                            currentUser: currentUser,
                          ).transitionToCreateRewardPage();
                        },
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
//              currentUser != null && currentUser.isCommunityBuilder
//                  ? menuRow(
//                        Icon(FontAwesomeIcons.newspaper, color: FlatColors.blackPearl, size: 18.0),
//                        'Post News',
//                        FlatColors.blackPearl,
//                          () {
//                            Navigator.pop(context);
//                            PageTransitionService(context: context, currentUser: currentUser).transitionToCommunityBuilderPage();
//                          },
//                      )
//                  : Container(height: 0, width: 0),
                menuRow(
                  Icon(FontAwesomeIcons.questionCircle,
                      color: currentUser.isNew
                          ? FlatColors.darkMountainGreen
                          : FlatColors.blackPearl,
                      size: 18.0),
                  'Help/FAQ',
                  FlatColors.blackPearl,
                  () {
                    Navigator.pop(context);
                    OpenUrl().launchInWebViewOrVC(
                        context, 'https://www.webblen.io/faq');
                  },
                ),
                menuRow(
                  Icon(
                    FontAwesomeIcons.signOutAlt,
                    color: FlatColors.blackPearl,
                    size: 18.0,
                  ),
                  'logout',
                  FlatColors.blackPearl,
                  () => ShowAlertDialogService().showLogoutDialog(context),
                ),
              ],
            ),
    );
  }
}
