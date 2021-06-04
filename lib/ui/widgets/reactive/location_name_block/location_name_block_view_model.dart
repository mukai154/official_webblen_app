import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/reactive/content_filter/reactive_content_filter_service.dart';

class LocationBlockViewModel extends ReactiveViewModel {
  ReactiveContentFilterService _reactiveContentFilterService = locator<ReactiveContentFilterService>();

  ///DATA
  String get cityName => _reactiveContentFilterService.cityName;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveContentFilterService];
}
