import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/models/webblen_event.dart';

class AgoraService {
  Future<String> retrieveAgoraToken(WebblenEvent event, int agoraUID) async {
    String token;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'retrieveAgoraToken',
    );

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'event': event.toMap(),
        'agoraUID': agoraUID,
      },
    ).catchError((e) {
      print(e.message);
    });
    if (result != null) {
      token = result.data['token'];
    }
    return token;
  }

  Future<String> startAgoraCloudRecording(WebblenEvent event, String uid, int streamerAgoraID, String token) async {
    String error;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'startAgoraCloudRecording',
    );

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'event': event.toMap(),
        'uid': uid,
        'streamerAgoraID': streamerAgoraID,
        'token': token,
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
