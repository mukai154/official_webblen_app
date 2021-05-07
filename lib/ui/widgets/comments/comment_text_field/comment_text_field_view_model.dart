import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class CommentTextFieldViewModel extends ReactiveViewModel {
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  List<WebblenUser> mentionedUsers = [];

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  addUserToMentions(WebblenUser user) {
    mentionedUsers.add(user);
    notifyListeners();
  }

  List<WebblenUser> getMentionedUsers({String? commentText}) {
    mentionedUsers.forEach((user) {
      if (!commentText!.contains(user.username!)) {
        mentionedUsers.remove(user);
      }
    });
    notifyListeners();
    return mentionedUsers;
  }

  clearMentionedUsers() {
    mentionedUsers = [];
    notifyListeners();
  }
}
