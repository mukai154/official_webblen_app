import 'package:permission_handler/permission_handler.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/app_colors.dart';

class CustomDialogService {
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();

  showErrorDialog({required String description}) async {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: "Error",
      description: description,
      buttonTitle: "Ok",
    );
  }

  showDetailedErrorDialog({required String title, required String description}) async {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: title,
      description: description,
      buttonTitle: "Ok",
    );
  }

  showSuccessDialog({required String title, required String description}) async {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: title,
      description: description,
      buttonTitle: "Ok",
    );
  }

  showPostDeletedDialog() {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: "Post Deleted",
      description: "Your post has been deleted",
      buttonTitle: "Ok",
    );
  }

  showStreamDeletedDialog() {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: "Stream Deleted",
      description: "Your stream has been deleted",
      buttonTitle: "Ok",
    );
  }

  showEventDeletedDialog() {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: "Event Deleted",
      description: "Your event has been deleted",
      buttonTitle: "Ok",
    );
  }

  showCancelContentDialog({required bool isEditing, required String contentType}) async {
    DialogResponse? response = await _dialogService.showDialog(
      title: isEditing ? "Cancel Editing $contentType?" : "Cancel Creating $contentType?",
      description:
          isEditing ? "Changes to this ${contentType.toLowerCase()} will not be saved" : "The details for this  ${contentType.toLowerCase()} will not be saved",
      cancelTitle: "Cancel",
      cancelTitleColor: appDestructiveColor(),
      buttonTitle: isEditing ? "Discard Changes" : "Discard Stream",
      buttonTitleColor: appTextButtonColor(),
      barrierDismissible: true,
    );
    if (response != null && !response.confirmed) {
      _navigationService.back();
    }
  }

  showPublishRecordingConfirmedDialog() {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: "Publishing Recording!",
      description: "A recording of this stream will be available for playback within the next 30 minutes",
      buttonTitle: "Ok",
    );
  }

  Future<bool> showNavigateToEarningsAccountDialog({required bool isEditing, required String contentType}) async {
    DialogResponse? response = await _dialogService.showDialog(
      title: "Create an Earnings Account?",
      description:
          isEditing ? "Changes to this ${contentType.toLowerCase()} will not be saved" : "The details for this ${contentType.toLowerCase()} will not be saved",
      cancelTitle: "Continue Editing",
      cancelTitleColor: appTextButtonColor(),
      buttonTitle: "Create Earnings Account",
      buttonTitleColor: appTextButtonColor(),
      barrierDismissible: true,
    );
    if (response != null && response.confirmed) {
      return true;
    }
    return false;
  }

  showEarningsAccountPendingAlert() {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: "Account Under Review",
      description: "Review can take up 24 hours\nPlease check back later",
      buttonTitle: "Ok",
    );
  }

  showFailedToSetupPaymentAccountDialog() {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: "Account Setup Error",
      description: "There was an Issue Adding Your Account\nPlease Verify Your Info and Try Again",
      buttonTitle: "Ok",
    );
  }

  showComingSoonDialog() {
    _dialogService.showDialog(
      barrierDismissible: true,
      title: "Coming Soon",
      description: "Webblen token features coming soon",
      buttonTitle: "Ok",
    );
  }

  showAppSettingsDialog({required String title, required String description}) async {
    DialogResponse? response =
        await _dialogService.showDialog(barrierDismissible: true, title: title, description: description, buttonTitle: "Open App Settings");
    if (response != null && response.confirmed) {
      openAppSettings();
    }
  }
}
