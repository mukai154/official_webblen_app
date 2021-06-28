import 'package:stacked/stacked.dart';
import 'package:webblen/models/webblen_live_stream.dart';

class ReactiveMiniVideoPlayerService with ReactiveServiceMixin {
  final _selectedStream = ReactiveValue<WebblenLiveStream>(WebblenLiveStream());
  final _selectedStreamCreator = ReactiveValue<String>("");

  WebblenLiveStream get selectedStream => _selectedStream.value;
  String get selectedStreamCreator => _selectedStreamCreator.value;

  void updateSelectedStream(WebblenLiveStream val) => _selectedStream.value = val;
  void updateSelectedStreamCreator(String val) => _selectedStreamCreator.value = val;

  void clearState() {
    _selectedStream.value = WebblenLiveStream();
    _selectedStreamCreator.value = "";
  }

  reactiveContentFilterService() {
    listenToReactiveValues([_selectedStream, _selectedStreamCreator]);
  }
}
