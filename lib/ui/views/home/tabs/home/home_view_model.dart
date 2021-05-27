import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/reactive/content_filter/reactive_content_filter_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/ui/views/base/app_base_view_model.dart';

class HomeViewModel extends ReactiveViewModel {
  ///SERVICES
  AppBaseViewModel appBaseViewModel = locator<AppBaseViewModel>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  ReactiveContentFilterService _reactiveContentFilterService = locator<ReactiveContentFilterService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///DATA
  WebblenUser get user => _reactiveUserService.user;
  String get cityName => _reactiveContentFilterService.cityName;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService, _reactiveContentFilterService];
}
