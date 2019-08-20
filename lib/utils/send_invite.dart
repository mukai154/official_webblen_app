import 'package:flutter_sms/flutter_sms.dart';

class SendInviteMessage {

// Future<Uri> getDynamicLink() async {
//   ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl(
//     Uri.parse('https://example.page.link/?link=https://example.com/&apn=com.example.android&ibn=com.example.ios')
//   );
// }

  void sendSMS(String message, List<String> recipents) async {
//    Uri dynamicUrl = await parameters.buildUrl();
    String _result = await FlutterSms
        .sendSMS(message: "Hey! You should download Webblen to find nearby communities. It also pays you to show up to events... 😉 https://webblen.io", recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
}