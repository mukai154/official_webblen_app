import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_event_ticket.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class TicketDistroDataService {
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  final CollectionReference ticketDistroRef = FirebaseFirestore.instance.collection("webblen_ticket_distros");
  final CollectionReference purchasedTicketRef = FirebaseFirestore.instance.collection("purchased_tickets");

  SnackbarService? _snackbarService = locator<SnackbarService>();

  Future<bool> checkIfTicketDistroExists(String id) async {
    bool exists = false;
    try {
      DocumentSnapshot snapshot = await ticketDistroRef.doc(id).get();
      if (snapshot.exists) {
        exists = true;
      }
    } catch (e) {
      return exists;
    }
    return exists;
  }

  Future createTicketDistro({required String eventID, required WebblenTicketDistro ticketDistro}) async {
    await ticketDistroRef.doc(eventID).set(ticketDistro.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future updateTicketDistro({required String eventID, required WebblenTicketDistro ticketDistro}) async {
    await ticketDistroRef.doc(eventID).update(ticketDistro.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future deleteTicketDistro({required String eventID}) async {
    await ticketDistroRef.doc(eventID).delete();
  }

  Future<WebblenTicketDistro> getTicketDistroByID(String? id) async {
    WebblenTicketDistro ticketDistro = WebblenTicketDistro();
    String? error;
    DocumentSnapshot snapshot = await ticketDistroRef.doc(id).get().catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Ticket Load Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      error = e.message;
    });
    if (error != null) {
      return ticketDistro;
    }
    if (snapshot.exists) {
      ticketDistro = WebblenTicketDistro.fromMap(snapshot.data()!);
    }
    return ticketDistro;
  }

  Future<bool> scanInTicket(String id) async {
    bool scannedIn = true;
    String? error;
    await purchasedTicketRef.doc(id).update({'used': true}).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      _customDialogService.showErrorDialog(description: "Error scanning ticket. Please try again");
      scannedIn = false;
    }
    return scannedIn;
  }

  FutureOr<WebblenEventTicket> getTicketByID(String? id) async {
    WebblenEventTicket ticket = WebblenEventTicket();
    String? error;

    DocumentSnapshot snapshot = await purchasedTicketRef.doc(id).get().catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Ticket Load Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      error = e.message;
    });
    if (error != null) {
      return ticket;
    }
    if (snapshot.exists) {
      ticket = WebblenEventTicket.fromMap(snapshot.data()!);
    }
    return ticket;
  }

  updateUsedDiscountCode({required String eventID, required WebblenTicketDistro ticketDistro, required String discountCode}) {
    int discountCodeIndex = ticketDistro.discountCodes!.indexWhere((code) => code['discountName'] == discountCode);
    if (discountCodeIndex >= 0) {
      Map<String, dynamic> code = ticketDistro.discountCodes![discountCodeIndex];
      int discountLimit = int.parse(code['discountLimit']);
      discountLimit = discountLimit - 1;
      ticketDistro.discountCodes![discountCodeIndex]['discountLimit'] = discountLimit.toString();
      updateTicketDistro(eventID: eventID, ticketDistro: ticketDistro);
    }
  }

  Future<List> completeTicketPurchase(String uid, List ticketsToPurchase, WebblenEvent event) async {
    List purchasedTickets = [];
    String? error;
    DocumentSnapshot snapshot = await ticketDistroRef.doc(event.id).get();
    print(snapshot);
    WebblenTicketDistro ticketDistro = WebblenTicketDistro.fromMap(snapshot.data()!);
    List validTicketIDs = ticketDistro.validTicketIDs == null ? [] : ticketDistro.validTicketIDs!.toList(growable: true);
    ticketsToPurchase.forEach((purchasedTicket) async {
      String ticketName = purchasedTicket['ticketName'];
      String ticketPrice = purchasedTicket['ticketPrice'];
      int ticketIndex = ticketDistro.tickets!.indexWhere((ticket) => ticket["ticketName"] == ticketName);
      int ticketPurchaseQty = purchasedTicket['purchaseQty'];
      int ticketAvailableQty = int.parse(purchasedTicket['ticketQuantity']);
      String newTicketAvailableQty = (ticketAvailableQty - ticketPurchaseQty).toString();
      ticketDistro.tickets![ticketIndex]['ticketQuantity'] = newTicketAvailableQty;
      for (int i = ticketPurchaseQty; i >= 1; i--) {
        String ticketID = getRandomString(32);
        validTicketIDs.add(ticketID);
        WebblenEventTicket newTicket = WebblenEventTicket(
          id: ticketID,
          name: ticketName,
          purchaserUID: uid,
          eventID: event.id,
          eventImageURL: event.imageURL,
          eventTitle: event.title,
          address: event.streetAddress,
          startDate: event.startDate,
          endDate: event.endDate,
          startTime: event.startTime,
          endTime: event.endTime,
          timezone: event.timezone,
          price: ticketPrice,
          ticketURL: "https://app.webblen.io/tickets/view/$ticketID",
        );
        purchasedTickets.add(newTicket.toMap());
        await purchasedTicketRef.doc(ticketID).set(newTicket.toMap()).catchError((e) {
          error = e;
        });
      }
      await ticketDistroRef.doc(event.id).update({
        "tickets": ticketDistro.tickets,
        "validTicketIDs": validTicketIDs,
      }).catchError((e) {
        error = e;
      });
    });
    return purchasedTickets;
  }

  Future<List<WebblenEventTicket>> getPurchasedTickets(String uid) async {
    List<WebblenEventTicket> eventTickets = [];
    QuerySnapshot snapshot = await purchasedTicketRef.where("purchaserUID", isEqualTo: uid).get();
    snapshot.docs.forEach((doc) {
      WebblenEventTicket ticket = WebblenEventTicket.fromMap(doc.data());
      eventTickets.add(ticket);
    });
    return eventTickets;
  }

  Future<List<WebblenEventTicket>> getPurchasedTicketsFromEvent(String uid, String eventID) async {
    List<WebblenEventTicket> eventTickets = [];
    QuerySnapshot snapshot = await purchasedTicketRef.where("purchaserUID", isEqualTo: uid).where("eventID", isEqualTo: eventID).get();
    snapshot.docs.forEach((doc) {
      WebblenEventTicket ticket = WebblenEventTicket.fromMap(doc.data());
      eventTickets.add(ticket);
    });
    return eventTickets;
  }
}
