import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/utils/copy_shareable_link.dart';

class AddContentSuccessfulBottomSheetModel extends BaseViewModel {
  SnackbarService _snackbarService = locator<SnackbarService>();
  UserDataService _userDataService = locator<UserDataService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();

  sharePostLink(WebblenPost post) async {
    String authorID = post.authorID;
    var userData = await _userDataService.getWebblenUserByID(authorID);
    if (userData is String) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: 'There was an issue sharing your post. Please try again.',
        duration: Duration(seconds: 3),
      );
      return;
    }
    WebblenUser user = userData;
    String url = await _dynamicLinkService.createPostLink(postAuthorUsername: "@${user.username}", post: post);
    _shareService.shareLink(url);
  }

  copyPostLink(WebblenPost post) async {
    String authorID = post.authorID;
    var userData = await _userDataService.getWebblenUserByID(authorID);
    if (userData is String) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: 'There was an issue sharing your post. Please try again.',
        duration: Duration(seconds: 3),
      );
      return;
    }
    WebblenUser user = userData;
    String url = await _dynamicLinkService.createPostLink(postAuthorUsername: "@${user.username}", post: post);
    copyShareableLink(link: url);
  }
}
