import 'package:flutter/services.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';

copyShareableLink({String link}) async {
  DialogService dialogService = locator<DialogService>();
  Clipboard.setData(ClipboardData(text: link));
  HapticFeedback.lightImpact();
  dialogService.showDialog(
    title: "Link Copied!",
    description: "",
    barrierDismissible: true,
    buttonTitle: "Ok",
  );
}
