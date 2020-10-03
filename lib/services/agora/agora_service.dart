import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/models/webblen_event.dart';

class AgoraService {
  Future<String> acquireAgoraResourceID(String eventID) async {
    String resourceID;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'acquireAgoraResourceID',
    );

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'eventID': eventID,
      },
    ).catchError((e) {
      print(e.message);
    });
    if (result != null) {
      print(result.data);
      resourceID = result.data;
    }
    return resourceID;
  }

  Future<String> startAgoraCloudRecording(String resourceID, String eventID, String uid, String streamerAgoraID) async {
    String error;
    print(streamerAgoraID);
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'startAgoraCloudRecording',
    );

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'resourceID': resourceID,
        'eventID': eventID,
        'uid': uid,
        'streamerAgoraID': streamerAgoraID,
      },
    ).catchError((e) {
      print(e.message);
    });
    if (result != null) {
      print(result.data['data'][0]);
    }
    return error;
  }

  Future<String> stopAgoraCloudRecording(WebblenEvent event, String uid, String streamerAgoraID) async {
    String error;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'startAgoraCloudRecording',
    );

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'event': event.toMap(),
        'uid': uid,
        'streamerAgoraID': streamerAgoraID,
      },
    ).catchError((e) {
      print(e.message);
    });
    if (result != null) {
      print(result.data['data'][0]);
    }
    return error;
  }
}
