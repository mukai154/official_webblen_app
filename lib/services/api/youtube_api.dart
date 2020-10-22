import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeAPI {

  // Future<http.Response> fetchAlbum() {
  //   return http.get('https://jsonplaceholder.typicode.com/albums/1');
  // }

  Future<String> createVideoBroadcast(String title, DateTime startDateTime, DateTime endDateTime, String apiKey, String accessToken) async {
    print(apiKey);
    //Set Broadcast Time
    String scheduledStartTime = startDateTime.toUtc().toIso8601String() + "Z";
    String scheduledEndTime = endDateTime.toUtc().toIso8601String() + "Z";

    //Set Broadcast Metadata
    Map<String, String> snippet = {
      "title": title,
      "scheduledStartTime": scheduledStartTime,
      "scheduledEndTime": scheduledEndTime,
    };

    Map<String, dynamic> contentDetails = {
      "enableAutoStart": true,
      "enableAutoStop": true,
    };

    Map<String, dynamic> status = {
      "privacyStatus": "public",
      //"madeForKids": false,
    };

    String body = json.encode({
      'snippet': snippet,
      'contentDetails': contentDetails,
      'status': status,
    });

    print(body);

    http.Response response = await http
        .post(
          'https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet%2CcontentDetails%2Cstatus&key=$apiKey',
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .catchError((e) => print(e));

    print("Response: ${response.body}");
    print("Status Code: ${response.statusCode}");
    return "executed";
  }
}
