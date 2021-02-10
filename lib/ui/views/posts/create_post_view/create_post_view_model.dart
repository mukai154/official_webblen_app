import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/post_data_service.dart';
import 'package:webblen/utils/string_validator.dart';
import 'package:webblen/utils/url_handler.dart';

class CreatePostViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  PostDataService _postDataService = locator<PostDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();

  ///HELPERS
  TextEditingController postTextController = TextEditingController();

  ///DATA
  bool isEditing = false;
  File img1;
  // File img2;
  // File img3;

  WebblenPost post;

  Future<bool> validateAndSubmitForm(
      {String name,
      String goal,
      String why,
      String who,
      String resources,
      String charityURL,
      String action1,
      String action2,
      String action3,
      String description1,
      String description2,
      String description3}) async {
    String formError;
    setBusy(true);
    if (!StringValidator().isValidString(name)) {
      formError = "Cause Name Required";
    } else if (!StringValidator().isValidString(goal)) {
      formError = "Please list your causes's goals";
    } else if (!StringValidator().isValidString(why)) {
      formError = "Please describe why your cause is important";
    } else if (!StringValidator().isValidString(who)) {
      formError = "Please describe who you are in regards to this cause";
    } else if (!StringValidator().isValidString(resources)) {
      formError = "Please provide additional resources for your cause";
    } else if (StringValidator().isValidString(charityURL) && !UrlHandler().isValidUrl(charityURL)) {
      formError = "Please provide a valid URL your cause";
    } else if (!StringValidator().isValidString(action1) || !StringValidator().isValidString(action2) || !StringValidator().isValidString(action3)) {
      formError = "Please provide 3 actions for your causes's followers to do";
    }
    if (formError != null) {
      setBusy(false);
      _dialogService.showDialog(
        title: "Form Error",
        description: formError,
        barrierDismissible: true,
      );
      return false;
    } else {
      String authorID = await _authService.getCurrentUserID();
      var res = await _postDataService.createPost(
        id: null,
        parentID: null,
        authorID: null,
        webAppLink: null,
        imageURL: null,
        nearbyZipcodes: null,
        paidOut: null,
        participantIDs: null,
        city: null,
        province: null,
        postDateTimeInMilliseconds: null,
        savedBy: null,
        sharedComs: null,
        tags: null,
        followers: null,
        reported: null,
        commentCount: null,
        postType: null,
        body: null,
      );
      // _causeDataService.createCause(
      //   creatorID: creatorID,
      //   name: name,
      //   goal: goal,
      //   why: why,
      //   who: who,
      //   resources: resources,
      //   charityURL: charityURL,
      //   actions: [action1, action2, action3],
      //   actionDescriptions: [description1, description2, description3],
      //   img1: img1,
      //   img2: img2,
      //   img3: img3,
      // );
      setBusy(false);
      if (res != null) {
        _dialogService.showDialog(
          title: "Form Submission Error",
          description: res,
          barrierDismissible: true,
        );
        return false;
      } else {
        return true;
      }
    }
  }

  ///BOTTOM SHEETS
  selectImage({BuildContext context, int imgNum, double ratioX, double ratioY}) async {
    File img;
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.imagePicker,
    );
    if (sheetResponse.responseData != null) {
      String res = sheetResponse.responseData;
      if (res == "camera") {
        // img = await GoImagePicker().retrieveImageFromCamera(ratioX: ratioX, ratioY: ratioY);
      } else if (res == "gallery") {
        // img = await GoImagePicker().retrieveImageFromLibrary(ratioX: ratioX, ratioY: ratioY);
      }
      // if (imgNum == 1) {
      //   img1 = img;
      // } else if (imgNum == 2) {
      //   img2 = img;
      // } else {
      //   img3 = img;
      // }
      notifyListeners();
    }
  }

  displayCauseUploadSuccessBottomSheet() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.postPublished,
      takesInput: false,
      barrierDismissible: true,
      customData: {
        'causeID': null,
      },
    );
    if (sheetResponse == null || sheetResponse.responseData != "return") {
      //_navigationService.pushNamedAndRemoveUntil(Routes.HomeNavViewRoute);
    }
  }

  ///NAVIGATION
  pushAndReplaceUntilHomeNavView() {
    //_navigationService.pushNamedAndRemoveUntil(Routes.HomeNavViewRoute);
  }

// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
