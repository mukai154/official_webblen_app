import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_content_gift_pool.dart';
import 'package:webblen/services/firestore/data/content_gift_pool_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

class GiftersBottomSheetModel extends StreamViewModel<WebblenContentGiftPool> {
  ///SERVICES
  UserDataService? _userDataService = locator<UserDataService>();
  ContentGiftPoolDataService _contentGiftPoolDataService = locator<ContentGiftPoolDataService>();

  ///CURRENT CONTENT GIFT POOL
  String? giftPoolID;
  late bool giftPoolExists;
  WebblenContentGiftPool giftPool = WebblenContentGiftPool();
  List gifters = [];

  initialize({required String? id}) async {
    setBusy(true);
    giftPoolID = id;
    giftPoolExists = await _contentGiftPoolDataService.checkIfGiftPoolExists(giftPoolID!);
    if (!giftPoolExists) {
      setBusy(false);
    }
    notifyListeners();
  }

  ///STREAM DATA
  @override
  void onData(WebblenContentGiftPool? data) {
    if (data != null) {
      if (data.isValid()) {
        giftPool = data;
        if (giftPool.gifters != null && giftPool.gifters!.isNotEmpty) {
          gifters = giftPool.gifters!.values.toList(growable: true);
          if (gifters.length > 1) {
            gifters.sort((a, b) => b['totalGiftAmount'].compareTo(a['totalGiftAmount']));
          }
        }
        notifyListeners();
        setBusy(false);
      }
    }
  }

  @override
  Stream<WebblenContentGiftPool> get stream => streamGiftPool();

  Stream<WebblenContentGiftPool> streamGiftPool() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      if (giftPoolID == null) {
        yield WebblenContentGiftPool();
      }
      WebblenContentGiftPool val = await _contentGiftPoolDataService.getGiftPoolByID(giftPoolID);
      yield val;
    }
  }
}
