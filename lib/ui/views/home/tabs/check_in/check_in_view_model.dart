import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/ui/views/base/app_base_view_model.dart';

class CheckInViewModel extends BaseViewModel {
  ///SERVICES
  AppBaseViewModel appBaseViewModel = locator<AppBaseViewModel>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
}
