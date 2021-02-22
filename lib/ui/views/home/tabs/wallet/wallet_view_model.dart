import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/services/auth/auth_service.dart';

@singleton
class WalletViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();

  ///BOTTOM SHEETS
  //bottom sheet for new post, stream, or event
  showAddContentOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.addContent,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "new post") {
        navigateToCreatePostPage();
      } else if (res == "new stream") {
        //
      } else if (res == "new event") {
        //
      }
      notifyListeners();
    }
  }

  //bottom sheet for post options
  showPostOptions() async {

  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
  navigateToCreatePostPage() {
    _navigationService.navigateTo(Routes.CreatePostViewRoute);
  }

}
