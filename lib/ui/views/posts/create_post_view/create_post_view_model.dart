import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/enums/post_type.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';
import 'package:webblen/utils/webblen_image_picker.dart';

class CreatePostViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  NavigationService _navigationService = locator<NavigationService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService _locationService = locator<LocationService>();
  FirestoreStorageService _firestoreStorageService = locator<FirestoreStorageService>();
  PostDataService _postDataService = locator<PostDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();

  ///HELPERS
  TextEditingController postTextController = TextEditingController();
  TextEditingController tagTextController = TextEditingController();
  bool textFieldEnabled = true;

  ///DATA
  WebblenUser currentUser;

  bool isEditing = false;
  File img;
  // File img2;
  // File img3;

  WebblenPost post = WebblenPost();

  ///WEBBLEN CURRENCY
  double newPostTaxRate;

  ///INITIALIZE
  initialize({BuildContext context}) async {
    setBusy(true);

    //get current user data
    String uid = await _authService.getCurrentUserID();
    var userData = await _userDataService.getWebblenUserByID(uid);
    if (userData is String) {
      _snackbarService.showSnackbar(
        title: 'Post Error',
        message: userData,
        duration: Duration(seconds: 3),
      );
      setBusy(false);
      return;
    }

    currentUser = userData;

    //check if editing existing post
    Map<String, dynamic> args = RouteData.of(context).arguments;
    String postID = args['postID'] ?? "";
    if (postID.isNotEmpty) {
      post = await _postDataService.getPostByID(postID);
      if (post != null) {
        postTextController.text = post.body;
        isEditing = true;
      }
    }

    //get webblen rates
    newPostTaxRate = await _platformDataService.getNewPostTaxRate();
    if (newPostTaxRate == null) {
      newPostTaxRate = 0.05;
    }
    notifyListeners();
    setBusy(false);
  }

  ///POST TAGS
  addTag(String tag) {
    List tags = post.tags == null ? [] : post.tags.toList(growable: true);

    //check if tag already listed
    if (!tags.contains(tag)) {
      //check if tag limit has been reached
      if (tags.length == 3) {
        _snackbarService.showSnackbar(
          title: 'Tag Limit Reached',
          message: 'You can only add up to 3 tags for your post',
          duration: Duration(seconds: 5),
        );
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
    List tags = post.tags == null ? [] : post.tags.toList(growable: true);
    tags.removeAt(index);
    post.tags = tags;
    notifyListeners();
  }

  ///POST LOCATION
  Future<bool> setPostLocation() async {
    bool success = true;

    //get current zip
    String zip = await _locationService.getCurrentZipcode();
    if (zip == null) {
      return false;
    }

    //get nearest zipcodes
    post.nearbyZipcodes = await _locationService.findNearestZipcodes(zip);
    if (post.nearbyZipcodes == null) {
      return false;
    }

    //get city
    post.city = await _locationService.getCurrentCity();
    if (post.city == null) {
      return false;
    }

    //get province
    post.province = await _locationService.getCurrentProvince();
    if (post.province == null) {
      return false;
    }

    return success;
  }

  ///FORM VALIDATION
  bool postBodyIsValid() {
    String message = postTextController.text;
    if (isValidString(message)) {
      return false;
    } else {
      return true;
    }
  }

  bool postTagsAreValid() {
    if (post.tags == null || post.tags.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool formIsValid() {
    bool isValid = false;
    if (!postTagsAreValid()) {
      _snackbarService.showSnackbar(
        title: 'Tag Error',
        message: 'Your post must contain at least 1 tag',
        duration: Duration(seconds: 3),
      );
    } else if (!postBodyIsValid()) {
      _snackbarService.showSnackbar(
        title: 'Post Message Required',
        message: 'The message for your post cannot be empty',
        duration: Duration(seconds: 3),
      );
    } else {
      isValid = true;
    }
    return isValid;
  }

  Future<bool> submitNewPost() async {
    bool success = true;

    //get current location
    bool setLocation = await setPostLocation();
    if (!setLocation) {
      _snackbarService.showSnackbar(
        title: 'Location Error',
        message: 'There was an issue posting to your location. Please try again.',
        duration: Duration(seconds: 3),
      );
      return false;
    }

    String message = postTextController.text.trim();

    //generate new post
    String newPostID = getRandomString(20);
    post = WebblenPost(
      id: newPostID,
      parentID: null,
      authorID: currentUser.id,
      imageURL: null,
      body: message,
      nearbyZipcodes: [],
      city: post.city,
      province: post.province,
      followers: currentUser.followers,
      tags: post.tags,
      webAppLink: "https://app.webblen.io/posts/post?id=$newPostID",
      sharedComs: [],
      savedBy: [],
      postType: PostType.eventPost,
      postDateTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      paidOut: false,
      participantIDs: [],
      commentCount: 0,
      reported: false,
    );

    //upload img if exists
    if (img != null) {
      String imageURL = await _firestoreStorageService.uploadImage(img: img, storageBucket: 'images', folderName: 'posts', fileName: post.id);
      if (imageURL == null) {
        _snackbarService.showSnackbar(
          title: 'Post Upload Error',
          message: 'There was an issue uploading your post. Please try again.',
          duration: Duration(seconds: 3),
        );
        return false;
      }
      post.imageURL = imageURL;
    }

    //upload post data
    var uploadResult = await _postDataService.createPost(post: post);
    if (uploadResult is String) {
      _snackbarService.showSnackbar(
        title: 'Post Upload Error',
        message: 'There was an issue uploading your post. Please try again.',
        duration: Duration(seconds: 3),
      );
      return false;
    }

    return success;
  }

  Future<bool> submitEditedPost() async {
    bool success = true;

    String message = postTextController.text.trim();

    //update post
    post = WebblenPost(
      id: post.id,
      parentID: post.parentID,
      authorID: currentUser.id,
      imageURL: img == null ? post.imageURL : null,
      body: message,
      nearbyZipcodes: post.nearbyZipcodes,
      city: post.city,
      province: post.province,
      followers: currentUser.followers,
      tags: post.tags,
      webAppLink: post.webAppLink,
      sharedComs: post.sharedComs,
      savedBy: post.savedBy,
      postType: PostType.eventPost,
      postDateTimeInMilliseconds: post.postDateTimeInMilliseconds,
      paidOut: post.paidOut,
      participantIDs: post.participantIDs,
      commentCount: post.commentCount,
      reported: post.reported,
    );

    //upload img if exists
    if (img != null) {
      String imageURL = await _firestoreStorageService.uploadImage(img: img, storageBucket: 'images', folderName: 'posts', fileName: post.id);
      if (imageURL == null) {
        _snackbarService.showSnackbar(
          title: 'Post Upload Error',
          message: 'There was an issue uploading your post. Please try again.',
          duration: Duration(seconds: 3),
        );
        return false;
      }
      post.imageURL = imageURL;
    }

    //upload post data
    var uploadResult = await _postDataService.updatePost(post: post);
    if (uploadResult is String) {
      _snackbarService.showSnackbar(
        title: 'Post Upload Error',
        message: 'There was an issue uploading your post. Please try again.',
        duration: Duration(seconds: 3),
      );
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
  selectImage({BuildContext context}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.imagePicker,
    );
    if (sheetResponse.responseData != null) {
      String res = sheetResponse.responseData;

      //disable text fields while fetching image
      textFieldEnabled = false;
      notifyListeners();

      //get image from camera or gallery
      if (res == "camera") {
        img = await WebblenImagePicker().retrieveImageFromCamera(ratioX: 1, ratioY: 1);
      } else if (res == "gallery") {
        img = await WebblenImagePicker().retrieveImageFromLibrary(ratioX: 1, ratioY: 1);
      }

      //wait a bit to re-enable text fields
      await Future.delayed(Duration(milliseconds: 500));
      textFieldEnabled = true;
      notifyListeners();
    }
  }

  showNewContentConfirmationBottomSheet({BuildContext context}) async {
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
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      title: "Publish Post?",
      description: "Publish this post for everyone to see",
      mainButtonTitle: "Publish Post",
      secondaryButtonTitle: "Cancel",
      customData: newPostTaxRate,
      variant: BottomSheetType.newContentConfirmation,
    );
    if (sheetResponse.responseData != null) {
      String res = sheetResponse.responseData;

      //disable text fields while fetching image
      textFieldEnabled = false;
      notifyListeners();

      //get image from camera or gallery
      if (res == "insufficient funds") {
        _snackbarService.showSnackbar(
          title: 'Insufficient Funds',
          message: 'You do no have enough WBLN to publish this post',
          duration: Duration(seconds: 3),
        );
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
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.postPublished,
      takesInput: false,
      customData: post,
      barrierDismissible: false,
    );
    if (sheetResponse == null || sheetResponse.responseData == "done") {
      _navigationService.pushNamedAndRemoveUntil(Routes.HomeNavViewRoute);
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