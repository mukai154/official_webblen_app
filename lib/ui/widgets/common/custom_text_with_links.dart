import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/utils/url_handler.dart';

final String urlPattern = r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?";
const String emailPattern = r'\S+@\S+';
const String phonePattern = r'[\d-]{9,}';
final RegExp linkRegExp = RegExp('($urlPattern)|($emailPattern)|($phonePattern)', caseSensitive: false);

List<TextSpan> linkify({required String text, double? fontSize}) {
  String modifiedText = text.replaceAll("\n", "!***NEWLINE***!");
  var linkMatches = linkRegExp.allMatches(modifiedText);

  List<TextSpan> linkedTextSpans = [];
  int lastIndex = 0;
  if (linkMatches.isEmpty) {
    return [
      TextSpan(
        text: text,
        style: TextStyle(
          color: appFontColor(),
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
      )
    ];
  }
  linkMatches.forEach((match) {
    TextSpan linkFreeText = TextSpan(
      text: modifiedText.substring(lastIndex, match.start).replaceAll("!***NEWLINE***!", "\n"),
      style: TextStyle(
        color: appFontColor(),
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      ),
    );
    TextSpan linkTextSpan = TextSpan(
      text: modifiedText.substring(match.start, match.end),
      style: TextStyle(
        color: appTextButtonColor(),
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          UrlHandler().launchInWebViewOrVC(modifiedText.substring(match.start, match.end));
        },
    );
    linkedTextSpans.add(linkFreeText);
    linkedTextSpans.add(linkTextSpan);
    lastIndex = match.end;
  });
  return linkedTextSpans;
}

// List<TextSpan> linkify(String text) {
//   List<TextSpan> linkifiedText = [];
//   List<String> words = separateWordsInString(text);
//
//   String linkFreePhrase = "";
//
//   //loop through words to find url or email
//   words.forEach((word) {
//     if (isValidUrl(word) || isValidEmail(word)) {
//       //initialize new text span
//       TextSpan linkTextSpan;
//
//       if (isValidUrl(word)) {
//         //create url text span
//         linkTextSpan = TextSpan(
//           text: word,
//           style: TextStyle(
//             color: appTextButtonColor(),
//             fontSize: 14.0,
//             fontWeight: FontWeight.w400,
//           ),
//           recognizer: TapGestureRecognizer()..onTap = () => UrlHandler().launchInWebViewOrVC(word),
//         );
//       } else {
//         //create email text span
//         linkTextSpan = TextSpan(
//           text: word,
//           style: TextStyle(
//             color: appTextButtonColor(),
//             fontSize: 14.0,
//             fontWeight: FontWeight.w400,
//           ),
//           recognizer: TapGestureRecognizer()..onTap = () => UrlHandler().openEmail(word),
//         );
//       }
//
//       //check if link-free phrase is empty before adding new text spans
//       if (linkFreePhrase.isEmpty) {
//         linkifiedText.add(linkTextSpan);
//       } else {
//         TextSpan linkFreeTextSpan = TextSpan(
//           text: linkifiedText.isEmpty ? linkFreePhrase : " $linkFreePhrase",
//           style: TextStyle(
//             color: appFontColor(),
//             fontSize: 14.0,
//             fontWeight: FontWeight.w400,
//           ),
//         );
//         linkifiedText.add(linkFreeTextSpan);
//         linkifiedText.add(linkTextSpan);
//         linkFreePhrase = "";
//       }
//     } else {
//       if (linkFreePhrase.isEmpty) {
//         linkFreePhrase = word;
//       } else {
//         linkFreePhrase = linkFreePhrase + " " + word;
//       }
//     }
//   });
//
//   //add remaining words to linkified text
//   if (linkFreePhrase.isNotEmpty) {
//     TextSpan linkFreeTextSpan = TextSpan(
//       text: linkifiedText.isEmpty ? linkFreePhrase : " $linkFreePhrase",
//       style: TextStyle(
//         color: appFontColor(),
//         fontSize: 14.0,
//         fontWeight: FontWeight.w400,
//       ),
//     );
//     linkifiedText.add(linkFreeTextSpan);
//   }
//
//   return linkifiedText;
// }
