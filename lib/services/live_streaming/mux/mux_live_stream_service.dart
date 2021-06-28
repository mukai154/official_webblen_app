import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';

class MuxLiveStreamService {
  completeStreamAndLinkMuxAsset({required WebblenLiveStream stream}) async {
    CustomDialogService _customDialogService = locator<CustomDialogService>();
    LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();

    if (stream.muxStreamID == null) {
      print('error closing mux stream due to null muxStreamID');
      return;
    } else if (stream.muxAssetPlaybackID != null) {
      _customDialogService.showErrorDialog(description: "A recording of this stream has already been published");
      return;
    }

    Map<String, dynamic>? muxStreamData = await retrieveMuxStream(muxStreamID: stream.muxStreamID!);

    if (muxStreamData != null) {
      if (muxStreamData['recent_asset_ids'] != null && muxStreamData['recent_asset_ids'].isNotEmpty) {
        String muxAssetID = muxStreamData['recent_asset_ids'][0];
        Map<String, dynamic>? muxAssetData = await retrieveMuxAsset(muxAssetID: muxAssetID);
        if (muxAssetData != null) {
          String muxAssetPlaybackID = muxAssetData['playback_ids'][0]['id'];
          double muxAssetDuration = muxAssetData['duration'];
          await _liveStreamDataService.updateStreamMuxAssetData(
              streamID: stream.id!, muxAssetPlaybackID: muxAssetPlaybackID, muxAssetDuration: muxAssetDuration);
          //close stream
          await completeMuxStream(muxStreamID: stream.muxStreamID!);
        }
      } else {
        _customDialogService.showErrorDialog(description: "No recording of this stream can be found");
      }
    } else {
      _customDialogService.showErrorDialog(description: "No recording of this stream can be found");
    }
  }

  deleteStreamAndAsset({required WebblenLiveStream stream}) async {
    Map<String, dynamic>? muxStreamData = await retrieveMuxStream(muxStreamID: stream.muxStreamID!);

    if (muxStreamData != null) {
      await deleteMuxStream(muxStreamID: stream.muxStreamID!);
      if (muxStreamData['recent_asset_ids'] != null && muxStreamData['recent_asset_ids'].isNotEmpty) {
        String muxAssetID = muxStreamData['recent_asset_ids'][0];
        await deleteMuxAsset(muxAssetID: muxAssetID);
      }
    }
  }

  ///cloud functions
  Future<Map<String, dynamic>?> createMuxStream({
    required WebblenLiveStream stream,
  }) async {
    Map<String, dynamic>? response;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'createMuxStream',
    );

    HttpsCallableResult result = await callable.call(<String, dynamic>{
      'streamID': stream.id,
      'twitchStreamKey': stream.twitchStreamKey ?? "",
      'youtubeStreamKey': stream.youtubeStreamKey ?? "",
      'fbStreamKey': stream.fbStreamKey ?? "",
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      print(result.data);
      response = result.data ?? null;
    }
    return response;
  }

  Future<void> completeMuxStream({
    required String muxStreamID,
  }) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'completeMuxStream',
    );

    await callable.call(<String, dynamic>{
      'muxStreamID': muxStreamID,
    }).catchError((e) {
      print(e);
    });
  }

  Future<Map<String, dynamic>?> retrieveMuxStream({
    required String muxStreamID,
  }) async {
    Map<String, dynamic>? response;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'retrieveMuxStream',
    );

    HttpsCallableResult result = await callable.call(<String, dynamic>{
      'muxStreamID': muxStreamID,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      print(result.data);
      response = result.data ?? null;
    }
    return response;
  }

  Future<Map<String, dynamic>?> deleteMuxStream({
    required String muxStreamID,
  }) async {
    Map<String, dynamic>? response;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'deleteMuxStream',
    );

    HttpsCallableResult result = await callable.call(<String, dynamic>{
      'muxStreamID': muxStreamID,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      print(result.data);
    }
    return response;
  }

  Future<Map<String, dynamic>?> retrieveMuxAsset({
    required String muxAssetID,
  }) async {
    Map<String, dynamic>? response;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'retrieveMuxAsset',
    );

    HttpsCallableResult result = await callable.call(<String, dynamic>{
      'muxAssetID': muxAssetID,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      print(result.data);
      response = result.data ?? null;
    }
    return response;
  }

  Future<Map<String, dynamic>?> deleteMuxAsset({
    required String muxAssetID,
  }) async {
    Map<String, dynamic>? response;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'deleteMuxAsset',
    );

    HttpsCallableResult result = await callable.call(<String, dynamic>{
      'muxAssetID': muxAssetID,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      print(result.data);
      response = result.data ?? null;
    }
    return response;
  }

  Future<String?> createSimulcastStream({
    required String muxStreamID,
    required String platformStreamURL,
    required String platformStreamKey,
    required String platformName,
  }) async {
    String? response;
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'createSimulcastStream',
    );

    HttpsCallableResult result = await callable.call(<String, dynamic>{
      'muxStreamID': muxStreamID,
      'platformStreamURL': platformStreamURL,
      'platformStreamKey': platformStreamKey,
      'platformName': platformName,
    }).catchError((e) {
      print(e);
    });

    if (result.data != null) {
      print(result.data);
    } else {
      print('issues streaming to $platformName');
    }
    return response;
  }
}
