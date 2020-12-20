import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/auth/auth_service.dart';

@singleton
class MessagesViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  // DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  CollectionReference notifsRef = FirebaseFirestore.instance.collection("user_notifications");

  ScrollController messagesScrollController = ScrollController();
  String uid;

  List<DocumentSnapshot> messageResults = [];
  DocumentSnapshot lastMessageDocSnap;

  bool loadingAdditionalMessages = false;
  bool moreMessagesAvailable = true;

  int resultsLimit = 20;

  initialize(String val) async {
    setBusy(true);
    uid = val;
    messagesScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * messagesScrollController.position.maxScrollExtent;
      if (messagesScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalMessages();
      }
    });
    notifyListeners();
    await loadMessages();
    setBusy(false);
  }

  Future<void> refreshData() async {
    messageResults = [];
    notifyListeners();
    await loadMessages();
  }

  loadMessages() async {
    QuerySnapshot snapshot = await notifsRef.where('uid', isEqualTo: uid).orderBy('notificationExpDate', descending: true).limit(15).get().catchError((e) {
      print(e);
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.docs.isNotEmpty) {
      lastMessageDocSnap = snapshot.docs[snapshot.docs.length - 1];
      messageResults = snapshot.docs;
    }
    notifyListeners();
  }

  loadAdditionalMessages() async {
    if (loadingAdditionalMessages || !moreMessagesAvailable) {
      return;
    }
    loadingAdditionalMessages = true;
    notifyListeners();
    QuerySnapshot snapshot = await notifsRef
        .where('uid', isEqualTo: uid)
        .orderBy('notificationExpDate', descending: true)
        .startAfterDocument(lastMessageDocSnap)
        .limit(15)
        .get()
        .catchError((e) {
      print(e);
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.docs.isNotEmpty) {
      lastMessageDocSnap = snapshot.docs[snapshot.docs.length - 1];
      messageResults.addAll(snapshot.docs);
    } else {
      moreMessagesAvailable = false;
    }
    loadingAdditionalMessages = false;
    notifyListeners();
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
//   navigateToCreateCauseView() {
//     _navigationService.navigateTo(Routes.CreateCauseViewRoute);
//   }

}
