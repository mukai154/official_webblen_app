import 'package:stacked/stacked.dart';

class USDBalanceHistoryViewModel extends BaseViewModel {
  ///FILTER DATA
  String searchTerm = "";

  updateSearchTerm(String val) {
    searchTerm = val.toLowerCase();
    notifyListeners();
  }
}
