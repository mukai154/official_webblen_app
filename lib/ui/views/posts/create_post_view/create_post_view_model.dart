import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/webblen_image_picker.dart';

class CreatePostViewModel extends ReactiveViewModel {
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  PlatformDataService? _platformDataService = locator<PlatformDataService>();
  UserDataService? _userDataService = locator<UserDataService>();
  LocationService? _locationService = locator<LocationService>();
  FirestoreStorageService? _firestoreStorageService = locator<FirestoreStorageService>();
  PostDataService? _postDataService = locator<PostDataService>();
  BottomSheetService? _bottomSheetService = locator<BottomSheetService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomBottomSheetService _customBottomSheetService = locator<CustomBottomSheetService>();

  ///HELPERS
  bool initializing = true;
  TextEditingController postTextController = TextEditingController();
  TextEditingController tagTextController = TextEditingController();
  bool textFieldEnabled = true;

  ///USER DATA
  bool? hasEarningsAccount;
  WebblenUser get user => _reactiveUserService.user;

  ///FILE DATA
  File? contentImageFile;

  ///DATA
  String? id;
  bool isEditing = false;

  WebblenPost post = WebblenPost();

  ///WEBBLEN CURRENCY
  double? newPostTaxRate;
  double? promo;

  ///REACTIVE SERVICES
  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  ///INITIALIZE
  initialize(String id) async {
    setBusy(true);

    //generate new stream
    post = WebblenPost().generateNewWebblenPost(authorID: user.id!, suggestedUIDs: user.followers == null ? [] : user.followers!);

    //check if editing existing post
    if (id != "new") {
      WebblenPost existingPost = await _postDataService!.getPostToEditByID(id);
      if (existingPost.isValid()) {
        post = existingPost;
        postTextController.text = post.body!;
        isEditing = true;
      }
    }

    //get webblen rates
    newPostTaxRate = await _platformDataService!.getNewPostTaxRate();
    if (newPostTaxRate == null) {
      newPostTaxRate = 0.05;
    }
    initializing = false;
    setBusy(false);
    notifyListeners();
  }

  ///POST TAGS
  addTag(String tag) {
    List tags = post.tags == null ? [] : post.tags!.toList(growable: true);

    //check if tag already listed
    if (!tags.contains(tag)) {
      //check if tag limit has been reached
      if (tags.length == 3) {
        _customDialogService.showErrorDialog(description: "You can only add up to 3 tags for your post");
      } else {
        //add tag
        tags.add(tag);
        post.tags = tags;
        notifyListeners();
      }
    }
    tagTextController.clear();
  }

  removeTagAtIndex(int index) {
    List tags = post.tags == null ? [] : post.tags!.toList(growable: true);
    tags.removeAt(index);
    post.tags = tags;
    notifyListeners();
  }

  ///POST MESSAGE
  setPostMessage(String val) {
    post.body = val.trim();
    notifyListeners();
  }

  ///POST LOCATION
  Future<bool> setPostLocation(Map<String, dynamic> details) async {
    bool success = true;
    setBusy(true);

    if (details.isEmpty) {
      _customDialogService.showErrorDialog(description: "There was an issue setting the location. Please try again.");
      return false;
    }

    //set nearest zipcodes
    post.nearbyZipcodes = await _locationService!.findNearestZipcodes(details['areaCode']);
    if (post.nearbyZipcodes == null) {
      _customDialogService.showErrorDialog(description: "There was an issue setting the location. Please try again.");
      return false;
    }

    //set lat
    post.lat = details['lat'];

    //set lon
    post.lon = details['lon'];

    //set city
    post.city = details['cityName'];

    //get province
    post.province = details['province'];

    notifyListeners();
    setBusy(false);

    return success;
  }

  ///FORM VALIDATION
  bool postBodyIsValid() {
    String message = postTextController.text;
    return isValidString(message);
  }

  bool postTagsAreValid() {
    if (post.tags == null || post.tags!.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool postLocationIsValid() {
    return isValidString(post.city);
  }

  bool formIsValid() {
    bool isValid = false;
    if (!postTagsAreValid()) {
      _customDialogService.showErrorDialog(description: "Your post must contain at least 1 tag");
    } else if (!postBodyIsValid()) {
      _customDialogService.showErrorDialog(description: "The message for your post cannot be empty");
    } else if (!postLocationIsValid()) {
      _customDialogService.showErrorDialog(description: "Please choose a location for your post");
    } else {
      isValid = true;
    }
    return isValid;
  }

  Future<bool> submitNewPost() async {
    bool success = true;

    //set post time
    post.postDateTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

    //upload img if exists
    if (contentImageFile != null) {
      String? imageURL = await _firestoreStorageService!.uploadImage(img: contentImageFile!, storageBucket: 'images', folderName: 'posts', fileName: post.id!);
      if (imageURL != null && imageURL.isEmpty) {
        _customDialogService.showErrorDialog(description: 'There was an issue uploading your post. Please try again.');
        return false;
      }
      post.imageURL = imageURL;
      notifyListeners();
    }

    //upload post data
    var uploadResult = await _postDataService!.createPost(post: post);
    if (uploadResult is String) {
      _customDialogService.showErrorDialog(description: 'There was an issue uploading your post. Please try again.');
      return false;
    }

    return success;
  }

  Future<bool> submitEditedPost() async {
    bool success = true;

    ///upload img if exists
    if (contentImageFile != null) {
      String? imageURL = await _firestoreStorageService!.uploadImage(img: contentImageFile!, storageBucket: 'images', folderName: 'posts', fileName: post.id!);
      if (imageURL != null && imageURL.isEmpty) {
        _customDialogService.showErrorDialog(description: 'There was an issue uploading your post. Please try again.');
        return false;
      }
      post.imageURL = imageURL;
      notifyListeners();
    }

    //upload post data
    var uploadResult = await _postDataService!.createPost(post: post);
    if (uploadResult is String) {
      _customDialogService.showErrorDialog(description: 'There was an issue uploading your post. Please try again.');
      return false;
    }

    return success;
  }

  submitForm() async {
    setBusy(true);

    //if editing update post, otherwise create new post
    if (isEditing) {
      //update post
      bool submittedPost = await submitEditedPost();
      if (submittedPost) {
        //show bottom sheet
        displayUploadSuccessBottomSheet();
      }
    } else {
      //submit new post
      bool submittedPost = await submitNewPost();
      if (submittedPost) {
        //show bottom sheet
        displayUploadSuccessBottomSheet();
      }
    }

    setBusy(false);
  }

  ///BOTTOM SHEETS
  selectImage() async {
    WebblenImagePicker().retrieveImageFromLibrary();
  }

  showNewContentConfirmationBottomSheet({BuildContext? context}) async {
    //exit function if form is invalid
    if (!formIsValid()) {
      setBusy(false);
      return;
    }

    //check if editing post
    if (isEditing) {
      submitForm();
      return;
    }

    //display post confirmation
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
      barrierDismissible: true,
      title: "Publish Post?",
      description: "Publish this post for everyone to see",
      mainButtonTitle: "Publish Post",
      secondaryButtonTitle: "Cancel",
      customData: {'fee': newPostTaxRate, 'promo': promo},
      variant: BottomSheetType.newContentConfirmation,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;

      //disable text fields while fetching image
      textFieldEnabled = false;
      notifyListeners();

      //get image from camera or gallery
      if (res == "insufficient funds") {
        _customDialogService.showErrorDialog(description: 'You do no have enough WBLN to publish this post');
      } else if (res == "confirmed") {
        submitForm();
      }

      //wait a bit to re-enable text fields
      await Future.delayed(Duration(milliseconds: 500));
      textFieldEnabled = true;
      notifyListeners();
    }
  }

  displayUploadSuccessBottomSheet() async {
    //deposit and/or withdraw webblen & promo
    if (promo != null) {
      await _userDataService!.depositWebblen(uid: user.id, amount: promo!);
    }
    await _userDataService!.withdrawWebblen(uid: user.id, amount: newPostTaxRate!);

    //display success
    var sheetResponse = await _bottomSheetService!.showCustomSheet(
        variant: BottomSheetType.addContentSuccessful,
        takesInput: false,
        customData: post,
        barrierDismissible: false,
        title: isEditing ? "Your Post has been Updated" : "Your Post has been Published! 🎉");

    if (sheetResponse == null || sheetResponse.responseData == "done") {
      _customNavigationService.navigateToBase();
    }
  }

  ///NAVIGATION
  navigateBack() async {
    bool confirmed = false;
    if (isEditing) {
      confirmed = await _customBottomSheetService.showCancelEditingContentBottomSheet();
    } else {
      confirmed = await _customBottomSheetService.showCancelCreatingContentBottomSheet(content: post);
    }
    if (confirmed) {
      _customNavigationService.navigateBack();
    }
  }
}
