import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/notifcation_type.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';

class NotificationBlockModel extends BaseViewModel {
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();

  onTap({String? notifType, Map<dynamic, dynamic>? data}) {
    if (notifType == NotificationType.post || notifType == NotificationType.postComment || notifType == NotificationType.postCommentReply) {
      _customNavigationService.navigateToPostView(data!['id']);
    } else if (notifType == NotificationType.event) {
      _customNavigationService.navigateToEventView(data!['id']);
    } else if (notifType == NotificationType.stream) {
      _customNavigationService.navigateToLiveStreamView(data!['id']);
    } else if (notifType == NotificationType.follower) {
      _customNavigationService.navigateToUserView(data!['id']);
    } else if (notifType == NotificationType.webblenReceived || notifType == NotificationType.webblenSent) {
      _customNavigationService.navigateToWalletView();
    } else if (notifType == NotificationType.tickets) {
      _customNavigationService.navigateToMyTicketsView();
    }
  }
}
