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
    this.areaName
  });

  Community.fromMap(Map<String, dynamic> data)
      : this (
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
      areaName: data['areaName']
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
    'areaName': this.areaName
  };
}