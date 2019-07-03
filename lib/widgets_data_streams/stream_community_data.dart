import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/widgets_community/community_row.dart';
import 'package:webblen/widgets_community/community_post_row.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/widgets_event/event_row.dart';


class StreamTopCommunities extends StatelessWidget {

  final WebblenUser currentUser;
  final String locRefID;
  StreamTopCommunities({this.currentUser, this.locRefID});

  final CollectionReference locRef = Firestore.instance.collection('available_locations');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: locRef.document(locRefID)
          .collection('communities')
          .orderBy('activityCount', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Community> communities = [];
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('Searching...', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
        } else {
          snapshot.data.documents.retainWhere((comDoc) => comDoc.data['status'] == 'active');
          if (snapshot.data.documents.isEmpty) return Padding(
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('No communities found in this area', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
          snapshot.data.documents.forEach((comDoc){
            Community community = Community.fromMap(comDoc.data);
            if (!communities.contains(community)){
              communities.add(community);
            }
          });
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            itemCount: communities.length,
            itemBuilder: (context, index){
              return CommunityRow(
                showAreaName: false,
                community: communities[index],
                onClickAction: () => PageTransitionService(context: context, currentUser: currentUser, community: communities[index]).transitionToCommunityProfilePage(),
              );
            },
          );
        }
      },
    );
  }
}

class StreamActiveCommunities extends StatelessWidget {

  final WebblenUser currentUser;
  final String locRefID;
  StreamActiveCommunities({this.currentUser, this.locRefID});

  final CollectionReference locRef = Firestore.instance.collection('available_locations');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: locRef.document(locRefID)
          .collection('communities')
          .orderBy('lastActivityTimeInMilliseconds', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Community> communities = [];
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('Searching...', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
        } else {
          snapshot.data.documents.retainWhere((comDoc) => comDoc.data['status'] == 'active');
          if (snapshot.data.documents.isEmpty) return Padding(
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('No communities found in this area', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
          snapshot.data.documents.forEach((comDoc){
            Community community = Community.fromMap(comDoc.data);
            if (!communities.contains(community)){
              communities.add(community);
            }
          });
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            itemCount: communities.length,
            itemBuilder: (context, index){
              return CommunityRow(
                showAreaName: false,
                community: communities[index],
                onClickAction: () => PageTransitionService(context: context, currentUser: currentUser, community: communities[index]).transitionToCommunityProfilePage(),
              );
            },
          );
        }
      },
    );
  }
}

class StreamMembersFollowers extends StatefulWidget {

  final double lat;
  final double lon;

  StreamMembersFollowers({this.lat, this.lon});

  @override
  _StreamMembersFollowersState createState() => _StreamMembersFollowersState();
}

class _StreamMembersFollowersState extends State<StreamMembersFollowers> {

  Geoflutterfire geo = Geoflutterfire();
  Widget streamWidget = Fonts().textW500("Searching...", 18.0, FlatColors.darkGray, TextAlign.left);

  @override
  Widget build(BuildContext context) {
    GeoFirePoint center = geo.point(latitude: widget.lat, longitude: widget.lon);
    CollectionReference locRef = Firestore.instance.collection("available_locations");
    return StreamBuilder(
      stream: geo.collection(collectionRef: locRef)
          .within(center: center, radius: 20, field: 'location'),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> docSnapshots){
        if (!docSnapshots.hasData) {
          return streamWidget;
        } else {
          List<Community> communities = [];
          docSnapshots.data.forEach((locSnapshot) async {
            QuerySnapshot communityQuery = await Firestore.instance
                .collection('available_locations')
                .document(locSnapshot.documentID)
                .collection('communities')
                .where('status', isEqualTo: 'active')
                .orderBy('activityCount', descending: true)
                .limit(10).getDocuments();
            communityQuery.documents.forEach((comDoc){
              Community community = Community.fromMap(comDoc.data);
              if (communities.contains(community)){
               communities.add(community);
              }
              if (communityQuery.documents.last == comDoc){
                setState(() {});
              }
            });
          });
          return ListView.builder(
            //padding: EdgeInsets.symmetric(vertical: 8.0),
            itemCount: communities.length,
            itemBuilder: (context, index){
              return CommunityRow(community: communities[index]);
            },
          );
        }
      },
    );
  }
}

class StreamCommunityNewsPosts extends StatelessWidget {

  final WebblenUser currentUser;
  final Community community;
  StreamCommunityNewsPosts({this.currentUser, this.community});

  final CollectionReference postsRef = Firestore.instance.collection('community_news');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: postsRef
          .where('communityName', isEqualTo: community.name)
          .where('areaName', isEqualTo: community.areaName)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<CommunityNewsPost> communityNews = [];
        if (!snapshot.hasData) {
          return Center(child: Fonts().textW500('Loading News...', 18.0, FlatColors.darkGray, TextAlign.center));
        } else {
          if (snapshot.data.documents.isEmpty) return Center(child: Fonts().textW300('This Community Has No Posts', 18.0, FlatColors.darkGray, TextAlign.center));
          snapshot.data.documents.forEach((postDoc){
            CommunityNewsPost post = CommunityNewsPost.fromMap(postDoc.data);
            if (!communityNews.contains(post)){
              communityNews.add(post);
            }
          });
          communityNews.sort((postA, postB) => postB.datePostedInMilliseconds.compareTo(postA.datePostedInMilliseconds));
          return ListView.builder(
            addAutomaticKeepAlives: true,
            padding: EdgeInsets.symmetric(vertical: 8.0),
            itemCount: communityNews.length,
            itemBuilder: (context, index){
              return CommunityPostRow(
                  newsPost: communityNews[index],
                  currentUser: currentUser,
                  showCommunity: false
              );
            },
          );
        }
      },
    );
  }
}

class StreamCommunitySpecialEvents extends StatelessWidget {

  final WebblenUser currentUser;
  final Community community;
  StreamCommunitySpecialEvents({this.currentUser, this.community});

  final CollectionReference eventRef = Firestore.instance.collection('events');

  @override
  Widget build(BuildContext context) {
    int currentDate = DateTime.now().millisecondsSinceEpoch;
    return StreamBuilder(
      stream: eventRef
          .where('communityName', isEqualTo: community.name)
          .where('communityAreaName', isEqualTo: community.areaName)
          .where('recurrence', isEqualTo: 'none')       //.orderBy('startDateInMilliseconds', descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Event> events = [];
        if (!snapshot.hasData) {
          return Center(child: Fonts().textW500('Searching For Events...', 18.0, FlatColors.darkGray, TextAlign.center));
        } else {
          if (snapshot.data.documents.isEmpty) return Container(
            color: FlatColors.clouds,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Fonts().textW300('This Community Has No Upcoming Events', 18.0, FlatColors.darkGray, TextAlign.center)),
          );
          snapshot.data.documents.forEach((eventDoc){
            if (eventDoc.data['startDateInMilliseconds'] > currentDate || (eventDoc.data['startDateInMilliseconds'] < currentDate && eventDoc.data['endDateInMilliseconds'] > currentDate)){
              Event event = Event.fromMap(eventDoc.data);
              if (!events.contains(event)){
                events.add(event);
              }
            }
          });
          events.sort((eventA, eventB) => eventA.startDateInMilliseconds.compareTo(eventB.startDateInMilliseconds));
          if (events.isEmpty) return Container(
            color: FlatColors.clouds,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Fonts().textW300('This Community Has No Upcoming Events', 18.0, FlatColors.darkGray, TextAlign.center)),
          );
          return Container(
            color: FlatColors.clouds,
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 4.0),
              itemCount: events.length,
              itemBuilder: (context, index){
                return ComEventRow(
                  event: events[index],
                  showCommunity: false,
                  eventPostAction: () => PageTransitionService(context: context, event: events[index], eventIsLive: false, currentUser: currentUser).transitionToEventPage(),
                );
              },
            ),
          );
        }
      },
    );
  }
}

class StreamCommunityDailyEvents extends StatelessWidget {

  final WebblenUser currentUser;
  final Community community;
  StreamCommunityDailyEvents({this.currentUser, this.community});

  final CollectionReference eventRef = Firestore.instance.collection('recurring_events');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: eventRef
          .where('comName', isEqualTo: community.name)
          .where('areaName', isEqualTo: community.areaName)
          .where('recurrenceType', isEqualTo: 'daily')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<RecurringEvent> events = [];
        if (!snapshot.hasData) {
          return Container();
        } else {
          if (snapshot.data.documents.isEmpty) return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 16.0),
                    child: Fonts().textW700('Daily Events', 18.0, FlatColors.darkGray, TextAlign.left),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Fonts().textW300('No Daily Events Found', 16.0, FlatColors.darkGray, TextAlign.center),
                  ),
                ],
              )
            ],
          );
          snapshot.data.documents.forEach((eventDoc){
            RecurringEvent event = RecurringEvent.fromMap(eventDoc.data);
            if (!events.contains(event)){
              events.add(event);
            }
          });
          return Container(
            //margin: EdgeInsets.only(bottom: 8.0),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 16.0),
                      child: Fonts().textW700('Daily Events', 18.0, FlatColors.darkGray, TextAlign.left),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: events.length,
                        itemBuilder: (context, index){
                          return ComRecurringEventRow(
                            event: events[index],
                            eventPostAction: () => PageTransitionService(context: context, recurringEvent: events[index], currentUser: currentUser).transitionToReccurringEventPage(),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
      },
    );
  }
}

class StreamCommunityWeeklyEvents extends StatelessWidget {

  final WebblenUser currentUser;
  final Community community;
  StreamCommunityWeeklyEvents({this.currentUser, this.community});

  final CollectionReference eventRef = Firestore.instance.collection('recurring_events');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: eventRef
          .where('comName', isEqualTo: community.name)
          .where('areaName', isEqualTo: community.areaName)
          .where('recurrenceType', isEqualTo: 'weekly')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<RecurringEvent> events = [];
        if (!snapshot.hasData) {
          return Container();
        } else {
          if (snapshot.data.documents.isEmpty) return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 24.0, left: 16.0),
                    child: Fonts().textW700('Weekly Events', 18.0, FlatColors.darkGray, TextAlign.left),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Fonts().textW300('No Weekly Events Found', 16.0, FlatColors.darkGray, TextAlign.center),
                  ),
                ],
              )
            ],
          );
          snapshot.data.documents.forEach((eventDoc){
            RecurringEvent event = RecurringEvent.fromMap(eventDoc.data);
            if (!events.contains(event)){
              events.add(event);
            }
          });
          return Container(
            margin: EdgeInsets.only(bottom: 8.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 24.0, left: 16.0),
                      child: Fonts().textW700('Weekly Events', 18.0, FlatColors.darkGray, TextAlign.left),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: events.length,
                        itemBuilder: (context, index){
                          return ComRecurringEventRow(
                            event: events[index],
                            eventPostAction: () => PageTransitionService(context: context, recurringEvent: events[index], currentUser: currentUser).transitionToReccurringEventPage(),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
      },
    );
  }
}

class StreamCommunityMonthlyEvents extends StatelessWidget {

  final WebblenUser currentUser;
  final Community community;
  StreamCommunityMonthlyEvents({this.currentUser, this.community});

  final CollectionReference eventRef = Firestore.instance.collection('recurring_events');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: eventRef
          .where('comName', isEqualTo: community.name)
          .where('areaName', isEqualTo: community.areaName)
          .where('recurrenceType', isEqualTo: 'monthly')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<RecurringEvent> events = [];
        if (!snapshot.hasData) {
          return Container();
        } else {
          if (snapshot.data.documents.isEmpty) return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 24.0, left: 16.0),
                    child: Fonts().textW700('Monthly Events', 18.0, FlatColors.darkGray, TextAlign.left),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Fonts().textW300('No Monthly Events Found', 16.0, FlatColors.darkGray, TextAlign.center),
                  ),
                ],
              )
            ],
          );
          snapshot.data.documents.forEach((eventDoc){
            RecurringEvent event = RecurringEvent.fromMap(eventDoc.data);
            if (!events.contains(event)){
              events.add(event);
            }
          });
          return Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 16.0),
                      child: Fonts().textW700('Monthly Events', 18.0, FlatColors.darkGray, TextAlign.left),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: events.length,
                        itemBuilder: (context, index){
                          return ComRecurringEventRow(
                            event: events[index],
                            eventPostAction: () => PageTransitionService(context: context, recurringEvent: events[index], currentUser: currentUser).transitionToReccurringEventPage(),
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
      },
    );
  }
}

class StreamMemberCommunities extends StatefulWidget {

  final WebblenUser currentUser;
  StreamMemberCommunities({this.currentUser});

  @override
  _StreamMemberCommunitiesState createState() => _StreamMemberCommunitiesState();
}

class _StreamMemberCommunitiesState extends State<StreamMemberCommunities> {

  final CollectionReference userRef = Firestore.instance.collection('users');
  final CollectionReference locRef = Firestore.instance.collection('available_locations');
  
  Widget dataWidget = Padding(
    padding: EdgeInsets.only(top: 45.0),
    child: Fonts().textW300('Retrieving Communities...', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
  );

  bool dataLoaded = false;

  @override
  Widget build(BuildContext context) {


    return StreamBuilder(
      stream: userRef.document(widget.currentUser.uid).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        List<Community> communities = [];
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: dataWidget
          );
        } else {
          Map<dynamic, dynamic> userCommunities = snapshot.data.data['communities'];
          if (userCommunities.isEmpty){
            dataWidget = Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: Fonts().textW300('No Communities Found', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
            );
          } else {
            int loopCount = 0;
            int loopMax = userCommunities.length;
            userCommunities.forEach((key, value){
              List areaCommunities = value;
              areaCommunities.forEach((comName){
                locRef.document(key).collection('communities').document(comName).get().then((docSnap){
                  if (docSnap.exists){
                    Community community = Community.fromMap(docSnap.data);
                    if (!communities.contains(communities) && community.status == "active"){
                      communities.add(community);
                      if (loopCount == loopMax || loopMax == 1){
                        if (!dataLoaded){
                          dataLoaded = true;
                          dataWidget = ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            itemCount: communities.length,
                            itemBuilder: (context, index){
                              return CommunityRow(
                                showAreaName: true,
                                community: communities[index],
                                onClickAction: () => PageTransitionService(context: context, currentUser: widget.currentUser, community: communities[index]).transitionToCommunityProfilePage(),
                              );
                            },
                          );
                          setState(() {});
                        }
                      } else {
                        loopCount += 1;
                      }
                    }
                  }
                });
              });
            });
          }
          return dataWidget;
        }
      },
    );
  }
}

class StreamUserCommunities extends StatelessWidget {

  final WebblenUser currentUser;
  final WebblenUser user;
  final String locRefID;
  StreamUserCommunities({this.currentUser, this.user, this.locRefID});

  final CollectionReference locRef = Firestore.instance.collection('available_locations');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: locRef.document(locRefID)
          .collection('communities')
          .where('members.${user.uid}', isEqualTo: user.profile_pic)
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Community> communities = [];
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('Searching...', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
        } else {
          if (snapshot.data.documents.isEmpty) return Padding(
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('@${user.username} is not a part of any community in this area.', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
          snapshot.data.documents.forEach((comDoc){
            Community community = Community.fromMap(comDoc.data);
            if (!communities.contains(community)){
              communities.add(community);
            }
          });
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.0),
            itemCount: communities.length,
            itemBuilder: (context, index){
              return CommunityRow(
                showAreaName: false,
                community: communities[index],
                onClickAction: () => PageTransitionService(context: context, currentUser: currentUser, community: communities[index]).transitionToCommunityProfilePage(),
              );
            },
          );
        }
      },
    );
  }
}

class StreamFollowedCommunities extends StatelessWidget {

  final WebblenUser currentUser;
  final String locRefID;
  StreamFollowedCommunities({this.currentUser, this.locRefID});

  final CollectionReference locRef = Firestore.instance.collection('available_locations');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: locRef.document(locRefID)
          .collection('communities')
          .where('followers', arrayContains: currentUser.uid)
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Community> communities = [];
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('Searching...', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
        } else {
          if (snapshot.data.documents.isEmpty) return Padding(
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('You are not following any communities in this area', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
          snapshot.data.documents.forEach((comDoc){
            Community community = Community.fromMap(comDoc.data);
            if (!communities.contains(community)){
              communities.add(community);
            }
          });
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            itemCount: communities.length,
            itemBuilder: (context, index){
              return CommunityRow(
                showAreaName: true,
                community: communities[index],
                onClickAction: () => PageTransitionService(context: context, currentUser: currentUser, community: communities[index]).transitionToCommunityProfilePage(),
              );
            },
          );
        }
      },
    );
  }
}

class StreamPendingCommunities extends StatelessWidget {

  final WebblenUser currentUser;
  final String locRefID;
  StreamPendingCommunities({this.currentUser, this.locRefID});

  final CollectionReference locRef = Firestore.instance.collection('available_locations');

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: locRef.document(locRefID)
          .collection('communities')
          .where('memberIDs', arrayContains: currentUser.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        List<Community> communities = [];
        if (!snapshot.hasData) {
          return Container(
            color: FlatColors.clouds,
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('Searching...', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
        } else {
          if (snapshot.data.documents.isEmpty) return Container(
            color: FlatColors.clouds,
            padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
            child: Fonts().textW300('No pending communities found in this area', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          );
          snapshot.data.documents.forEach((comDoc){
            Community community = Community.fromMap(comDoc.data);
            if (!communities.contains(community)){
              communities.add(community);
            }
          });
          return Container(
            color: FlatColors.clouds,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              itemCount: communities.length,
              itemBuilder: (context, index){
                return CommunityRow(
                  showAreaName: true,
                  community: communities[index],
                  onClickAction: () => PageTransitionService(context: context, currentUser: currentUser, community: communities[index]).transitionToCommunityProfilePage(),
                );
              },
            ),
          );
        }
      },
    );
  }
}

