import 'package:stacked/stacked.dart';

class ReactiveContentFilterService with ReactiveServiceMixin {
  final _cityName = ReactiveValue<String>("");
  final _areaCode = ReactiveValue<String>("");
  final _tagFilter = ReactiveValue<String>("");
  final _sortByFilter = ReactiveValue<String>("Latest");

  String get cityName => _cityName.value;
  String get areaCode => _areaCode.value;
  String get tagFilter => _tagFilter.value;
  String get sortByFilter => _sortByFilter.value;

  void updateCityName(String val) => _cityName.value = val;
  void updateAreaCode(String val) => _areaCode.value = val;
  void updateTagFilter(String val) => _tagFilter.value = val;
  void updateSortByFilter(String val) => _sortByFilter.value = val;

  reactiveContentFilterService() {
    listenToReactiveValues([_cityName, _areaCode, _tagFilter, _sortByFilter]);
  }
}
