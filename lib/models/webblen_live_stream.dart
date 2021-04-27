import 'package:flutter/material.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class WebblenLiveStream {
  String? id;
  String? hostID;
  bool? hasTickets;
  String? title;
  String? description;
  String? imageURL;
  String? audienceLocation;
  List? nearbyZipcodes;
  String? city;
  String? province;
  double? lat;
  double? lon;
  List? sharedComs;
  List? tags;
  int? clicks;
  String? website;
  String? fbUsername;
  String? twitterUsername;
  String? instaUsername;
  int? actualTurnout;
  List? viewers;
  double? payout;
  int? startDateTimeInMilliseconds;
  int? endDateTimeInMilliseconds;
  String? startDate;
  String? startTime;
  String? endDate;
  String? endTime;
  String? timezone;
  String? privacy;
  bool? reported;
  String? webAppLink;
  List? savedBy;
  bool? paidOut;
  bool? openToSponsors;
  List<Map<dynamic, dynamic>>? gifters;
  double? totalGiftAmount;
  List? suggestedUIDs;

  WebblenLiveStream({
    this.id,
    this.hostID,
    this.hasTickets,
    this.title,
    this.description,
    this.imageURL,
    this.nearbyZipcodes,
    this.city,
    this.province,
    this.audienceLocation,
    this.lat,
    this.lon,
    this.sharedComs,
    this.tags,
    this.clicks,
    this.website,
    this.fbUsername,
    this.twitterUsername,
    this.instaUsername,
    this.actualTurnout,
    this.viewers,
    this.payout,
    this.startDateTimeInMilliseconds,
    this.endDateTimeInMilliseconds,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.timezone,
    this.privacy,
    this.reported,
    this.webAppLink,
    this.savedBy,
    this.paidOut,
    this.openToSponsors,
    this.gifters,
    this.totalGiftAmount,
    this.suggestedUIDs,
  });

  WebblenLiveStream.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          hostID: data['hostID'],
          hasTickets: data['hasTickets'],
          title: data['title'],
          description: data['description'],
          imageURL: data['imageURL'],
          nearbyZipcodes: data['nearbyZipcodes'],
          audienceLocation: data['audienceLocation'],
          city: data['city'],
          province: data['province'],
          lat: data['lat'],
          lon: data['lon'],
          sharedComs: data['sharedComs'],
          tags: data['tags'],
          clicks: data['clicks'],
          website: data['website'],
          fbUsername: data['fbUsername'],
          twitterUsername: data['twitterUsername'],
          instaUsername: data['instaUsername'],
          actualTurnout: data['actualTurnout'],
          viewers: data['viewers'],
          payout: data['payout'] == null ? null : data['payout'] * 1.001,
          startDateTimeInMilliseconds: data['startDateTimeInMilliseconds'],
          endDateTimeInMilliseconds: data['endDateTimeInMilliseconds'],
          startDate: data['startDate'],
          startTime: data['startTime'],
          endDate: data['endDate'],
          endTime: data['endTime'],
          timezone: data['timezone'],
          privacy: data['privacy'],
          reported: false,
          webAppLink: data['webAppLink'],
          savedBy: data['savedBy'],
          paidOut: data['paidOut'],
          openToSponsors: data['openToSponsors'],
          gifters: data['gifters'],
          totalGiftAmount: data['totalGiftAmount'],
          suggestedUIDs: data['suggestedUIDs'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'hostID': this.hostID,
        'hasTickets': this.hasTickets,
        'title': this.title,
        'description': this.description,
        'imageURL': this.imageURL,
        'nearbyZipcodes': this.nearbyZipcodes,
        'audienceLocation': this.audienceLocation,
        'city': this.city,
        'province': this.province,
        'lat': this.lat,
        'lon': this.lon,
        'sharedComs': this.sharedComs,
        'tags': this.tags,
        'clicks': this.clicks,
        'website': this.website,
        'fbUsername': this.fbUsername,
        'twitterUsername': this.twitterUsername,
        'instaUsername': this.instaUsername,
        'actualTurnout': this.actualTurnout,
        'viewers': this.viewers,
        'payout': this.payout,
        'startDateTimeInMilliseconds': this.startDateTimeInMilliseconds,
        'endDateTimeInMilliseconds': this.endDateTimeInMilliseconds,
        'startDate': this.startDate,
        'startTime': this.startTime,
        'endDate': this.endDate,
        'endTime': this.endTime,
        'timezone': this.timezone,
        'privacy': this.privacy,
        'reported': this.reported,
        'webAppLink': this.webAppLink,
        'savedBy': this.savedBy,
        'paidOut': this.paidOut,
        'openToSponsors': this.openToSponsors,
        'gifters': this.gifters,
        'totalGiftAmount': this.totalGiftAmount,
        'suggestedUIDs': this.suggestedUIDs,
      };

  WebblenLiveStream generateNewWebblenLiveStream({required String? hostID}) {
    String id = getRandomString(30);
    WebblenLiveStream stream = WebblenLiveStream(
      id: id,
      hostID: hostID,
      privacy: "Public",
      reported: false,
      hasTickets: false,
      paidOut: false,
      openToSponsors: false,
      tags: [],
      savedBy: [],
      viewers: [],
      clicks: 0,
    );
    return stream;
  }
}
