import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class NewContentConfirmationBottomSheetModel extends ReactiveViewModel {
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  WebblenUser get user => _reactiveUserService.user;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];
}
