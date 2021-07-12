import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/ui/widgets/mini_video_player/mini_video_player_view_model.dart';

class ExpandedLandscapeMiniPlayerViewModel extends BaseViewModel {
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  MiniVideoPlayerViewModel miniVideoPlayerViewModel = locator<MiniVideoPlayerViewModel>();

  initialize() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  toggleLandscapeMode() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _customNavigationService.navigateBack();
  }
}
