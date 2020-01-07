import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:webblen/firebase_data/webblen_notification_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';

class WebblenScanner extends StatefulWidget {
  final WebblenUser currentUser;

  WebblenScanner({
    this.currentUser,
  });

  @override
  _WebblenScannerState createState() => _WebblenScannerState();
}

class _WebblenScannerState extends State<WebblenScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String dataType = "";
  String data = "";
  String additionalData = "";
  QRViewController controller;

  void sendFriendRequest(String uid, String username) async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService()
        .checkIfFriendRequestExists(
      widget.currentUser.uid,
      uid,
    )
        .then((exists) {
      if (exists) {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          "Friend Request Pending",
          "You Already Have a Pending Request with $username",
        );
      } else {
        WebblenNotificationDataService()
            .sendFriendRequest(
          widget.currentUser.uid,
          uid,
          widget.currentUser.username,
        )
            .then((error) {
          Navigator.of(context).pop();
          if (error.isEmpty) {
            ShowAlertDialogService().showActionSuccessDialog(
                context,
                "Friend Request Sent!",
                username + " Will Need to Confirm Your Request", () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
          } else {
            ShowAlertDialogService().showFailureDialog(
              context,
              "Request Failed",
              error,
            );
          }
        });
      }
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      //print(scanData);
      controller.pauseCamera();
      if (!scanData.contains("addFriend.")) {
        ShowAlertDialogService().showFailureDialog(
          context,
          "That's Odd",
          "We Don't Recongnize this Code...",
        );
      } else {
        int dataSplitterIndex = scanData.indexOf(".", 0);
        int dataSplitterIndex2 = scanData.indexOf("-", 0);
        dataType = scanData.substring(
          0,
          dataSplitterIndex,
        );
        data = scanData.substring(
          dataSplitterIndex + 1,
          dataSplitterIndex2,
        );
        additionalData = scanData.substring(
          dataSplitterIndex2 + 1,
          scanData.length,
        );
        if (data == widget.currentUser.uid) {
          ShowAlertDialogService().showFailureDialog(
            context,
            "That's Odd",
            "This is Your Account...",
          );
        } else if (dataType == "addFriend") {
          String uid = data;
          String username = "@" + additionalData;
          ShowAlertDialogService().showScannedAccount(
            context,
            username,
            uid,
            () => sendFriendRequest(
              uid,
              username,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar(
        'Scan Code',
        context,
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }
}
