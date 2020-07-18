import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:webblen/firebase_data/comment_data.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class CommunityCreatePostPage extends StatefulWidget {
  final WebblenUser currentUser;
  final Community community;

  CommunityCreatePostPage({
    this.currentUser,
    this.community,
  });

  @override
  _CommunityCreatePostPageState createState() => _CommunityCreatePostPageState();
}

class _CommunityCreatePostPageState extends State<CommunityCreatePostPage> {
  //Firebase
  File newsImage;
  CommunityNewsPost newsPost = CommunityNewsPost();
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final communityPostKey = GlobalKey<FormState>();

  //Form Validations
  void validateNews() async {
    ScaffoldState scaffold = homeScaffoldKey.currentState;
    final form = communityPostKey.currentState;
    form.save();
    if (newsPost.title.isEmpty) {
      scaffold.showSnackBar(
        SnackBar(
          content: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Text(
              "Title Cannot be Empty",
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(
            milliseconds: 800,
          ),
        ),
      );
    } else if (newsPost.content.isEmpty) {
      scaffold.showSnackBar(
        SnackBar(
          content: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Text(
              "Post Cannot be Empty",
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(
            milliseconds: 800,
          ),
        ),
      );
    } else if (newsPost.newsURL.isNotEmpty && !OpenUrl().isValidUrl(newsPost.newsURL)) {
      scaffold.showSnackBar(
        SnackBar(
          content: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Text(
              "Url is Invalid",
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(
            milliseconds: 800,
          ),
        ),
      );
    } else {
      newsPost.communityName = widget.community.name;
      newsPost.areaName = widget.community.areaName;
      newsPost.username = widget.currentUser.username;
      newsPost.userImageURL = widget.currentUser.profile_pic;
      newsPost.datePostedInMilliseconds = DateTime.now().millisecondsSinceEpoch;
      uploadNewsPost(
        newsImage,
        newsPost,
      );
    }
  }

  void setNewsPostImage(bool getImageFromCamera) async {
    Navigator.of(context).pop();
    newsImage = null;
    setState(() {});
    newsImage = getImageFromCamera
        ? await WebblenImagePicker(
            context: context,
            ratioX: 9.0,
            ratioY: 7.0,
          ).retrieveImageFromCamera()
        : await WebblenImagePicker(
            context: context,
            ratioX: 9.0,
            ratioY: 7.0,
          ).retrieveImageFromLibrary();
    if (newsImage != null) {
      setState(() {});
    }
  }

  void cropImage(File img) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: img.path,
      aspectRatio: CropAspectRatio(
        ratioX: 9,
        ratioY: 7,
      ),
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Image Cropper',
        toolbarColor: FlatColors.clouds,
      ),
    );
    if (croppedFile != null) {
      newsImage = croppedFile;
      setState(() {});
    }
  }

  uploadNewsPost(File image, CommunityNewsPost newsPost) async {
    ShowAlertDialogService().showLoadingDialog(context);
    await CommunityDataService().uploadNews(image, newsPost).then((error) {
      if (error.isEmpty) {
        CommentDataService().startChat(newsPost.postID);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          'Uh Oh!',
          'There was an issue uploading your post. Please try again.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget addImageButton() {
      return GestureDetector(
        onTap: () => ShowAlertDialogService().showImageSelectDialog(
          context,
          () => setNewsPostImage(true),
          () => setNewsPostImage(false),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 300.0,
          decoration: BoxDecoration(
            color: Colors.black12,
          ),
          child: newsImage == null
              ? Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 40.0,
                    color: FlatColors.londonSquare,
                  ),
                )
              : Image.file(
                  newsImage,
                  fit: BoxFit.cover,
                ),
        ),
      );
    }

    Widget _buildNewsTitleField() {
      return new Container(
        margin: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: TextFormField(
            initialValue: "",
            maxLength: 30,
            maxLengthEnforced: true,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 30.0,
              fontWeight: FontWeight.w700,
            ),
            autofocus: false,
            onSaved: (value) => newsPost.title = value,
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
              hintText: "Post Title",
              counterStyle: TextStyle(fontFamily: 'Barlow'),
              contentPadding: EdgeInsets.fromLTRB(
                8.0,
                10.0,
                8.0,
                10.0,
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildPostContent() {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 2.0,
          horizontal: 16.0,
        ),
        height: 150.0,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: TextFormField(
            initialValue: "",
            maxLines: 10,
            maxLength: 500,
            maxLengthEnforced: true,
            textInputAction: TextInputAction.done,
            autofocus: false,
            onSaved: (value) => newsPost.content = value,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "What Do You Have to Say?",
              counterStyle: TextStyle(
                fontFamily: 'Barlow',
              ),
              contentPadding: EdgeInsets.fromLTRB(
                10.0,
                4.0,
                10.0,
                10.0,
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildNewsUrlField() {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: TextFormField(
            initialValue: "",
            maxLines: 1,
            autofocus: false,
            onSaved: (value) => newsPost.newsURL = value,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Post Url/ Youtube URL (Optional)",
              counterStyle: TextStyle(
                fontFamily: 'Barlow',
              ),
              contentPadding: EdgeInsets.fromLTRB(
                10.0,
                10.0,
                10.0,
                10.0,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: homeScaffoldKey,
      appBar: WebblenAppBar().basicAppBar(
        'Create News Post',
        context,
      ),
      body: Container(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: ListView(
            children: <Widget>[
              Form(
                key: communityPostKey,
                child: Column(
                  children: <Widget>[
                    addImageButton(),
                    SizedBox(
                      height: 8.0,
                    ),
                    _buildNewsTitleField(),
                    SizedBox(
                      height: 8.0,
                    ),
                    _buildPostContent(),
                    SizedBox(
                      height: 8.0,
                    ),
                    _buildNewsUrlField(),
                    SizedBox(
                      height: 8.0,
                    ),
                    CustomColorButton(
                      text: "Submit Post",
                      textColor: FlatColors.darkGray,
                      backgroundColor: Colors.white,
                      height: 45.0,
                      width: 200.0,
                      onPressed: () => validateNews(),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
