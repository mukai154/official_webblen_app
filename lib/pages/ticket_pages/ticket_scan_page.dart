import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class TicketScanPage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenEvent event;

  TicketScanPage({
    this.currentUser,
    this.event,
  });

  @override
  _TicketScanPageState createState() => _TicketScanPageState();
}

class _TicketScanPageState extends State<TicketScanPage> {
  bool isLoading = true;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  List validTicketIDs = [];
  List usedTicketIDs = [];
  String dataType = "";
  String data = "";
  String additionalData = "";
  QRViewController controller;

  void loadTicketDistro() async {
    EventDataService().getEventTicketDistro(widget.event.id).then((res) {
      validTicketIDs = res.validTicketIDs.toList(growable: true);
      usedTicketIDs = res.usedTicketIDs.toList(growable: true);
      isLoading = false;
      setState(() {});
    });
  }

  void scanTicket(String scannedTicket) async {
    isLoading = true;
    setState(() {});
    if (validTicketIDs.contains(scannedTicket)) {
      validTicketIDs.remove(scannedTicket);
      usedTicketIDs.add(scannedTicket);
      await Future.delayed(Duration(seconds: 2));
      EventDataService().updateScannedTickets(widget.event.id, validTicketIDs, usedTicketIDs).then((error) {
        if (error.isEmpty) {
          isLoading = false;
          setState(() {});
          HapticFeedback.lightImpact();
          ShowAlertDialogService().showSuccessDialog(context, "Ticket Validated!", "This Ticket is Valid!");
        } else {
          isLoading = false;
          setState(() {});
          HapticFeedback.vibrate();
          ShowAlertDialogService().showFailureDialog(context, "That's Odd...", "There was an issue verifying this ticket. Please try again.");
        }
      });
    } else if (usedTicketIDs.contains(scannedTicket)) {
      await Future.delayed(Duration(seconds: 2));
      isLoading = false;
      setState(() {});
      ShowAlertDialogService().showInfoDialog(context, "Used Ticket", "This Ticket Has Already Been Used");
    } else {
      await Future.delayed(Duration(seconds: 2));
      isLoading = false;
      setState(() {});
      HapticFeedback.vibrate();
      ShowAlertDialogService().showFailureDialog(context, "Invalid Ticket", "This Code is Not a Ticket for this Event");
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      //scanTicket(scanData);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTicketDistro();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().ticketScannerAppBar(context, "Scanning Tickets...", widget.event.title),
      body: isLoading
          ? CustomLinearProgress(progressBarColor: FlatColors.webblenRed)
          : Container(
              child: GestureDetector(
              onTap: () => controller.resumeCamera(),
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            )),
    );
  }
}
