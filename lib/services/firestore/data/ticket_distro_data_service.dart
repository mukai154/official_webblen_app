import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';import 'package:webblen/models/webblen_ticket_distro.dart';

class TicketDistroDataService {
  final CollectionReference ticketDistroRef = FirebaseFirestore.instance.collection("webblen_ticket_distros");

  SnackbarService? _snackbarService = locator<SnackbarService>();

  Future<bool?> checkIfTicketDistroExists(String id) async {
    bool exists = false;
    try {
      DocumentSnapshot snapshot = await ticketDistroRef.doc(id).get();
      if (snapshot.exists) {
        exists = true;
      }
    } catch (e) {
      _snackbarService!.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return null;
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

  Future getTicketDistroByID(String? id) async {
    WebblenTicketDistro? ticketDistro;
    DocumentSnapshot snapshot = await ticketDistroRef.doc(id).get().catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Ticket Load Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return null;
    });
    if (snapshot.exists) {
      ticketDistro = WebblenTicketDistro.fromMap(snapshot.data()!);
    }
    return ticketDistro;
  }
}
