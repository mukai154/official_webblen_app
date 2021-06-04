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

  Future<bool> updateTicketDistroQuantities({required String eventID, required String ticketName, required int numOfTicketsPurchased}) async {
    if (numOfTicketsPurchased == 0) {
      return true;
    }
    //print('updating ticket quantities');
    String? error;
    DocumentSnapshot snapshot = await ticketDistroRef.doc(eventID).get();
    WebblenTicketDistro ticketDistro = WebblenTicketDistro.fromMap(snapshot.data()!);
    int ticketIndex = ticketDistro.tickets!.indexWhere((ticket) => ticket["ticketName"] == ticketName);
    int numOfTicketsAvailable = int.parse(ticketDistro.tickets![ticketIndex]['ticketQuantity']);
    String newTicketAvailableQty = (numOfTicketsAvailable - numOfTicketsPurchased).toString();
    ticketDistro.tickets![ticketIndex]['ticketQuantity'] = newTicketAvailableQty;
    //print('updating ticket $ticketName qty data to ${ticketDistro.tickets![ticketIndex]['ticketQuantity'].toString()}');
    await ticketDistroRef.doc(eventID).update({"tickets": ticketDistro.tickets}).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      print('failed to update ticket quantities: $error');
      return false;
    }
    //print('update success');
    return true;
  }

  Future<List> completeTicketPurchase({required String uid, required WebblenEvent event, required List ticketsToPurchase}) async {
    List tickets = [];
    for (var val in ticketsToPurchase) {
      String ticketName = val['ticketName'];
      String ticketPrice = val['ticketPrice'];
      int numOfTicketsPurchased = val['purchaseQty'];
      for (int i = numOfTicketsPurchased; i >= 1; i--) {
        String ticketID = getRandomString(32);
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
          used: false,
        );
        tickets.add(newTicket.toMap());
        await purchasedTicketRef.doc(ticketID).set(newTicket.toMap()).catchError((e) {
          print(e);
        });
        await ticketDistroRef.doc(event.id).update({
          "validTicketIDs": FieldValue.arrayUnion([ticketID])
        });
      }
      await updateTicketDistroQuantities(eventID: event.id!, ticketName: ticketName, numOfTicketsPurchased: numOfTicketsPurchased);
    }
    return tickets;
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
