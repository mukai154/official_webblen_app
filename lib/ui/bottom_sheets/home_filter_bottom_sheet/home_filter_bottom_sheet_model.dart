import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/google_places_service.dart';
import 'package:webblen/services/reactive/content_filter/reactive_content_filter_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/ui/widgets/home_feed/home_feed_model.dart';

class HomeFilterBottomSheetModel extends BaseViewModel {
  ///SERVICES
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  ReactiveContentFilterService _reactiveContentFilterService = locator<ReactiveContentFilterService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  UserDataService _userDataService = locator<UserDataService>();
  GooglePlacesService googlePlacesService = locator<GooglePlacesService>();
  AlgoliaSearchService algoliaSearchService = locator<AlgoliaSearchService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  HomeFeedModel _homeFeedModel = locator<HomeFeedModel>();

  bool updatingData = false;

  ///DATA
  String get cityName => _reactiveContentFilterService.cityName;
  String get areaCode => _reactiveContentFilterService.areaCode;
  String get tagFilter => _reactiveContentFilterService.tagFilter;
  String get contentType => _homeFeedModel.contentType;
  String get sortByFilter => _reactiveContentFilterService.sortByFilter;
  WebblenUser get user => _reactiveUserService.user;

  ///TEMPORARY DATA
  String tempCityName = "";
  String tempAreaCode = "";
  String tempTagFilter = "";
  String tempContentType = "";
  String tempSortByFilter = "Latest";

  ///FILTERS
  List<String> contentTypeList = ["Posts, Streams, and Events", "Posts Only", "Streams & Video Only", "Live Only", "Events Only"];
  List<String> sortByList = ["Latest", "Most Popular"];
  Map<String, dynamic> placeSearchResults = {};

  ///API KEYS
  String? googleAPIKey;

  ///INITIALIZE
  initialize() async {
    tempCityName = cityName;
    tempAreaCode = areaCode;
    tempTagFilter = tagFilter;
    tempContentType = contentType;
    tempSortByFilter = sortByFilter;
    googleAPIKey = await _platformDataService.getGoogleApiKey();
    notifyListeners();
  }

  updateContentType(String val) {
    tempContentType = val;
    notifyListeners();
  }

  updateSortByFilter(String val) {
    tempSortByFilter = val;
    notifyListeners();
  }

  setPlacesSearchResults(Map<String, dynamic> val) {
    placeSearchResults = val;
    notifyListeners();
  }

  setTagFilter(String val) async {
    tempTagFilter = val;
    notifyListeners();
  }

  ///CLEAR FILTERS
  clearLocationFilter() {
    tempCityName = "Worldwide";
    tempAreaCode = "";
    notifyListeners();
  }

  clearTagFilter() {
    tempTagFilter = "";
    notifyListeners();
  }

  ///GET LOCATION DETAILS
  getPlaceDetails(String place) async {
    updatingData = true;
    notifyListeners();
    String placeID = placeSearchResults[place];
    await googlePlacesService.getDetailsFromPlaceID(key: googleAPIKey, placeID: placeID).then((details) {
      if (details.isNotEmpty) {
        setPlacesSearchResults(details);
        tempCityName = details['cityName'];
        tempAreaCode = details['areaCode'];
        updatingData = false;
        notifyListeners();
      } else {
        _customDialogService.showErrorDialog(description: "There was an issue getting the details of this location. Please try again.");
      }
    });
  }

  ///UPDATE PREFERENCES
  updatePreferences() {
    _reactiveContentFilterService.updateCityName(tempCityName);
    _reactiveContentFilterService.updateAreaCode(tempAreaCode);
    _reactiveContentFilterService.updateSortByFilter(tempSortByFilter);
    _reactiveContentFilterService.updateTagFilter(tempTagFilter);
    _homeFeedModel.updateContentType(tempContentType);
    notifyListeners();
    updateUserData();
  }

  updateUserData() async {
    if (tempAreaCode.isNotEmpty && tempAreaCode != areaCode) {
      _userDataService.updateLastSeenZipcode(id: user.id, zip: tempAreaCode);
    }
  }
}
