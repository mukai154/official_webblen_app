class Community {
  String name;
  String status;
  List followers;
  int activityCount;
  int eventCount;
  int postCount;
  List posts;
  List last100Events;
  List subtags;
  List memberIDs;
  int lastActivityTimeInMilliseconds;
  bool isPrivate;
  String communityType;
  String areaName;

  Community({
    this.name,
    this.status,
    this.followers,
    this.activityCount,
    this.eventCount,
    this.postCount,
    this.posts,
    this.last100Events,
    this.subtags,
    this.memberIDs,
    this.lastActivityTimeInMilliseconds,
    this.isPrivate,
    this.communityType,
    this.areaName,
  });

  Community.fromMap(Map<String, dynamic> data)
      : this(
          name: data['name'],
          status: data['status'],
          followers: data['followers'],
          activityCount: data['activityCount'],
          eventCount: data['eventCount'],
          postCount: data['postCount'],
          posts: data['posts'],
          last100Events: data['last100Events'],
          subtags: data['subtags'],
          memberIDs: data['memberIDs'],
          lastActivityTimeInMilliseconds: data['lastActivityTimeInMilliseconds'],
          isPrivate: data['isPrivate'],
          communityType: data['communityType'],
          areaName: data['areaName'],
        );

  Map<String, dynamic> toMap() => {
        'name': this.name,
        'status': this.status,
        'followers': this.followers,
        'activityCount': this.activityCount,
        'eventCount': this.eventCount,
        'postCount': this.postCount,
        'posts': this.posts,
        'last100Events': this.last100Events,
        'subtags': this.subtags,
        'memberIDs': this.memberIDs,
        'lastActivityTimeInMilliseconds': this.lastActivityTimeInMilliseconds,
        'isPrivate': this.isPrivate,
        'communityType': this.communityType,
        'areaName': this.areaName,
      };
}

class WebblenCommunity {
  String id;
  String name;
  List members;
  List admin;
  List postIDs;
  List pendingSharedEvents;
  List nearbyZipcodes;
  List nearbyCities;
  String comImgURL;
  List tags;
  bool isPrivate;
  String status;
  bool reported;
  int activityCount;
  int lastActivityTimeInMilliseconds;

  WebblenCommunity({
    this.id,
    this.name,
    this.members,
    this.admin,
    this.postIDs,
    this.pendingSharedEvents,
    this.nearbyZipcodes,
    this.nearbyCities,
    this.comImgURL,
    this.tags,
    this.isPrivate,
    this.status,
    this.reported,
    this.activityCount,
    this.lastActivityTimeInMilliseconds,
  });

  WebblenCommunity.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          name: data['name'],
          members: data['members'],
          admin: data['admin'],
          postIDs: data['postIDs'],
          pendingSharedEvents: data['pendingSharedEvents'],
          nearbyZipcodes: data['nearbyZipcodes'],
          nearbyCities: data['nearbyCities'],
          comImgURL: data['comImgURL'],
          tags: data['tags'],
          isPrivate: data['isPrivate'],
          status: data['status'],
          reported: data['reported'],
          activityCount: data['activityCount'],
          lastActivityTimeInMilliseconds: data['lastActivityTimeInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'name': this.name,
        'members': this.members,
        'admin': this.admin,
        'postIDs': this.postIDs,
        'pendingSharedEvents': this.pendingSharedEvents,
        'nearbyZipcodes': this.nearbyZipcodes,
        'nearbyCities': this.nearbyCities,
        'comImgURL': this.comImgURL,
        'tags': this.tags,
        'isPrivate': this.isPrivate,
        'status': this.status,
        'reported': this.reported,
        'activityCount': this.activityCount,
        'lastActivityTimeInMilliseconds': this.lastActivityTimeInMilliseconds,
      };
}
