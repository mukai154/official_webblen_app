import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/notifcation_type.dart';

class NotificationBlockModel extends BaseViewModel {
  // AuthService _authService = locator<AuthService>();
  NavigationService _navigationService = locator<NavigationService>();
  // UserDataService _userDataService = locator<UserDataService>();
  // BottomSheetService _bottomSheetService = locator<BottomSheetService>();

  onTap({String notifType, Map<dynamic, dynamic> data}) {
    if (notifType == NotificationType.post || notifType == NotificationType.postComment || notifType == NotificationType.postCommentReply) {
      navigateToPostView(data['id']);
    }
  }

  ///NAVIGATION
  navigateToCauseView(String id) {
    //_navigationService.navigateTo(Routes.CauseViewRoute, arguments: {'id': id});
  }

  navigateToPostView(String id) {
    _navigationService.navigateTo(Routes.PostViewRoute, arguments: {'id': id});
  }

  navigateToUserView(String uid) {
    //_navigationService.navigateTo(Routes.UserViewRoute, arguments: {'uid': uid});
  }
}
