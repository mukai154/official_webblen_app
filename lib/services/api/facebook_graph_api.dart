import 'dart:convert';

import 'package:http/http.dart' as http;

class FacebookGraphAPI {
  Future<String> getUserID(String accessToken) async {
    String id;
    http.Response response = await http.get('https://graph.facebook.com/me?access_token=$accessToken').catchError((e) => print(e));
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      id = body['id'];
      print(id);
    }
    return id;
  }
}
