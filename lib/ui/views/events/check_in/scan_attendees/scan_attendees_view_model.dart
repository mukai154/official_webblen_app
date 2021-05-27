import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';

class ScanAttendeesViewModel extends StreamViewModel<WebblenEvent> {
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  EventDataService _eventDataService = locator<EventDataService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  ///QR CODE SCANNER
  GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewController;

  ///EVENT DATA
  WebblenEvent event = WebblenEvent();
  bool scanning = false;
  bool? scanError;
  List scannedTickets = [];

  initialize(String? id) {
    setBusy(true);
    if (id != null) {
      event.id = id;
      notifyListeners();
    }
  }

  void onQRViewCreated(QRViewController controller) {
    qrViewController = controller;
    qrViewController!.scannedDataStream.listen((scanData) async {
      String ticketID = scanData.code;
      controller.pauseCamera();
      scanning = true;
      notifyListeners();
      if (!scannedTickets.contains(ticketID)) {
        bool checkedIn = await _eventDataService.checkInScannedTicket(ticketID: ticketID, eventID: event.id!);
        if (checkedIn) {
          scannedTickets.add(ticketID);
          scanError = false;
        } else {
          scanError = true;
        }
      } else {
        scanError = true;
        _customDialogService.showErrorDialog(description: "You've already scanned this ticket");
        HapticFeedback.heavyImpact();
        HapticFeedback.heavyImpact();
      }
      scanning = false;
      notifyListeners();
      controller.resumeCamera();
    });
  }

  resumeScanner() {
    if (qrViewController != null) {
      qrViewController!.resumeCamera();
    }
  }

  @override
  void onData(WebblenEvent? data) async {
    if (data != null) {
      if (data.isValid()) {
        if (data != event) {
          event = data;
          notifyListeners();
          setBusy(false);
        }
      }
    }
  }

  @override
  Stream<WebblenEvent> get stream => streamEventDetails();

  Stream<WebblenEvent> streamEventDetails() async* {
    while (true) {
      WebblenEvent val = WebblenEvent();
      if (event.id == null) {
        yield val;
      }
      await Future.delayed(Duration(seconds: 1));
      val = await _eventDataService.getEventByID(event.id!);
      yield val;
    }
  }
}
