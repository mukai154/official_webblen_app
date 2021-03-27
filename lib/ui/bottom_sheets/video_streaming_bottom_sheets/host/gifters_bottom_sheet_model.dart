import 'package:auto_route/auto_route.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_content_gift_pool.dart';
import 'package:webblen/services/firestore/data/content_gift_pool_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';

class GiftersBottomSheetModel extends StreamViewModel<WebblenContentGiftPool> {
  ///SERVICES
  WebblenBaseViewModel _webblenBaseViewModel = locator<WebblenBaseViewModel>();
  UserDataService _userDataService = locator<UserDataService>();
  ContentGiftPoolDataService _contentGiftPoolDataService = locator<ContentGiftPoolDataService>();

  ///CURRENT CONTENT GIFT POOL
  String giftPoolID;
  bool giftPoolExists;
  WebblenContentGiftPool giftPool;

  initialize({@required String id}) async {
    setBusy(true);
    giftPoolID = id;
    giftPoolExists = await _contentGiftPoolDataService.checkIfGiftPoolExists(giftPoolID);
    if (!giftPoolExists) {
      setBusy(false);
    }
    notifyListeners();
  }

  ///STREAM DATA
  @override
  void onData(WebblenContentGiftPool data) {
    if (data != null) {
      giftPool = data;
      notifyListeners();
      setBusy(false);
    }
  }

  @override
  Stream<WebblenContentGiftPool> get stream => streamGiftPool();

  Stream<WebblenContentGiftPool> streamGiftPool() async* {
    while (true) {
      if (giftPoolID == null) {
        yield null;
      }
      await Future.delayed(Duration(seconds: 1));
      WebblenContentGiftPool val = await _contentGiftPoolDataService.getGiftPoolByID(giftPoolID);
      yield val;
    }
  }
}
