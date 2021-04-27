import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/webblen_image_picker.dart';

class EditProfileViewModel extends BaseViewModel {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  UserDataService? _userDataService = locator<UserDataService>();

  TextEditingController bioTextController = TextEditingController();
  TextEditingController websiteTextController = TextEditingController();

  late Map<String, dynamic> args;

  bool updatingData = false;

  File? updatedProfilePic;
  String? updatedBio;
  String? id;
  String initialProfilePicURL = "";
  String initialProfileBio = "";
  String initialWebsiteLink = "";

  initialize(BuildContext context) async {
    setBusy(true);
    await getParams(context);
    notifyListeners();
    setBusy(false);
  }

  getParams(BuildContext context) async {
    id = args['id'] ?? "";
    WebblenUser user = await (_userDataService!.getWebblenUserByID(id) as FutureOr<WebblenUser>);
    initialProfilePicURL = user.profilePicURL ?? "";
    bioTextController.text = user.bio ?? "";
    websiteTextController.text = user.website ?? "";
  }

  selectImage() async {
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.imagePicker,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "camera") {
        updatedProfilePic = await WebblenImagePicker().retrieveImageFromCamera(ratioX: 1, ratioY: 1);
      } else if (res == "gallery") {
        updatedProfilePic = await WebblenImagePicker().retrieveImageFromLibrary(ratioX: 1, ratioY: 1);
      }
      notifyListeners();
      if (updatedProfilePic != null) {
        await _userDataService!.updateProfilePic(id!, updatedProfilePic!);
      }
    }
  }

  websiteIsValid() {
    bool isValid = isValidUrl(websiteTextController.text.trim());
    if (!isValid) {
      _snackbarService!.showSnackbar(
        title: 'Website Error',
        message: 'Please provide a valid website URL.',
        duration: Duration(seconds: 5),
      );
    }
    return isValid;
  }

  updateProfile() async {
    updatingData = true;
    notifyListeners();
    bool updateSuccessFul = true;

    //update bio
    updateSuccessFul = await _userDataService!.updateBio(id: id, bio: bioTextController.text.trim());

    //update website link
    if (websiteTextController.text.trim().isNotEmpty) {
      if (websiteIsValid()) {
        updateSuccessFul = await _userDataService!.updateWebsite(id: id, website: websiteTextController.text.trim());
      } else {
        updateSuccessFul = false;
      }
    } else if (websiteTextController.text.trim().isEmpty) {
      updateSuccessFul = await _userDataService!.updateWebsite(id: id, website: websiteTextController.text.trim());
    }

    if (updateSuccessFul) {
      navigateBack();
    } else {
      updatingData = false;
      notifyListeners();
    }
  }

  ///NAVIGATION
  navigateBack() {
    _navigationService!.back();
  }
}
