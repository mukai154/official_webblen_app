import 'package:webblen/models/webblen_user.dart';

class SearchService {

  List<WebblenUser> searchForUserByName(List<WebblenUser> nearbyUsers, String val) {
    print(val);
    List<WebblenUser> results = nearbyUsers.where((user) => user.username.contains(val));
    print(results);
    return results;
  }
}