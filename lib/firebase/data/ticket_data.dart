import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/event_ticket.dart';
import 'package:webblen/models/ticket_distro.dart';

class TicketDataService {
  final CollectionReference ticketsRef = FirebaseFirestore.instance.collection("purchased_tickets");
  final CollectionReference ticketDistroRef = FirebaseFirestore.instance.collection("ticket_distros");

  //CREATE
  Future<String> uploadEventTickets(String eventID, TicketDistro ticketDistro) async {
    String error;
    await ticketDistroRef.doc(eventID).set(ticketDistro.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  //READ
  Future<TicketDistro> getEventTicketDistro(String eventID) async {
    TicketDistro ticketDistro;
    DocumentSnapshot snapshot = await ticketDistroRef.doc(eventID).get();
    if (snapshot.exists) {
      ticketDistro = TicketDistro.fromMap(snapshot.data());
    }
    return ticketDistro;
  }

  Future<List<EventTicket>> getPurchasedTickets(String uid) async {
    List<EventTicket> eventTickets = [];
    QuerySnapshot snapshot = await ticketsRef.where("purchaserUID", isEqualTo: uid).get();
    snapshot.docs.forEach((doc) {
      EventTicket ticket = EventTicket.fromMap(doc.data());
      eventTickets.add(ticket);
    });
    return eventTickets;
  }

  Future<List<EventTicket>> getPurchasedTicketsFromEvent(String uid, String eventID) async {
    List<EventTicket> eventTickets = [];
    QuerySnapshot snapshot = await ticketsRef.where("purchaserUID", isEqualTo: uid).where("eventID", isEqualTo: eventID).get();
    snapshot.docs.forEach((doc) {
      EventTicket ticket = EventTicket.fromMap(doc.data());
      eventTickets.add(ticket);
    });
    return eventTickets;
  }

  Future<String> updateScannedTickets(String eventKey, List validTickets, List usedTickets) async {
    String error = "";
    await ticketDistroRef.doc(eventKey).update({
      "validTicketIDs": validTickets,
      "usedTicketIDs": usedTickets,
    }).catchError((e) {
      error = e;
    });
    return error;
  }

  Future<String> updateUsedDiscountCodes(TicketDistro ticketDistro, String eventID) async {
    String error = "";
    await ticketDistroRef.doc(eventID).update({
      "discountCodes": ticketDistro.discountCodes,
    }).catchError((e) {
      error = e;
    });
    return error;
  }
}
