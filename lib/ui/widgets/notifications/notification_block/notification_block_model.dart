import 'package:stacked/stacked.dart';
import 'package:webblen/enums/notifcation_type.dart';

class NotificationBlockModel extends BaseViewModel {
  // AuthService _authService = locator<AuthService>();
  // NavigationService _navigationService = locator<NavigationService>();
  // UserDataService _userDataService = locator<UserDataService>();
  // BottomSheetService _bottomSheetService = locator<BottomSheetService>();

  onTap({NotificationType notifType, Map<dynamic, dynamic> data}) {
    // if (notifType == NotificationType.newPost.toString() ||
    //     notifType == NotificationType.postComment.toString() ||
    //     notifType == NotificationType.postCommentReply.toString()) {
    //   navigateToPostView(data['postID']);
    // }
  }

  ///NAVIGATION
  navigateToCauseView(String id) {
    //_navigationService.navigateTo(Routes.CauseViewRoute, arguments: {'id': id});
  }

  navigateToPostView(String id) {
    //_navigationService.navigateTo(Routes.ForumPostViewRoute, arguments: {'postID': id});
  }

  navigateToUserView(String uid) {
    //_navigationService.navigateTo(Routes.UserViewRoute, arguments: {'uid': uid});
  }
}