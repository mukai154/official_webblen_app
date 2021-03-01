import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_event.dart';

class EventDataService {
  CollectionReference eventTicketsRef =
      FirebaseFirestore.instance.collection('webblen_events');
  SnackbarService _snackbarService = locator<SnackbarService>();

  Future createEvent({@required WebblenEvent event}) async {
    DocumentReference newDocRef = eventTicketsRef.doc();
    await newDocRef.set(event.toMap(newDocRef.id)).catchError((e) {
      return e.message;
    });
  }

  Future getEventByID(String id) async {
    WebblenEvent event;
    DocumentSnapshot snapshot = await eventTicketsRef.doc(id).get().catchError((e) {
      print(e.message);
      return _snackbarService.showSnackbar(
        title: 'Post Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.exists) {
      event = WebblenEvent.fromMap(snapshot.data());
    }
    return event;
  }
}
