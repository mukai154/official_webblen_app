import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class UploadStreamVideoPage extends StatefulWidget {
  final WebblenEvent event;
  final WebblenUser currentUser;
  UploadStreamVideoPage({this.event, this.currentUser});

  @override
  _UploadStreamVideoPageState createState() => _UploadStreamVideoPageState();
}

class _UploadStreamVideoPageState extends State<UploadStreamVideoPage> {
  Subscription compressProgressSub;
  VideoCompress videoCompress = VideoCompress();
  File vidFile;
  String uid;
  String username;
  bool isUploading = false;
  String uploadStatus;

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final usernameFormKey = GlobalKey<FormState>();
  final userSetupScaffoldKey = GlobalKey<ScaffoldState>();

  //Form Validations
  Future<Null> uploadFile() async {
    String downloadUrl;

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("stream_video")
        .child(widget.currentUser.uid)
        .child("${widget.event.id}${DateTime.now().millisecondsSinceEpoch}.mp4");
    if (vidFile == null) {
      ShowAlertDialogService().showFailureDialog(context, "Video Missing", "Please Select a Video to Upload");
    } else {
      UploadTask uploadTask = ref.putFile(
        vidFile,
        SettableMetadata(
          contentType: 'video/mp4',
        ),
      );
      uploadTask.snapshotEvents.forEach((event) {
        int percentComplete = ((event.bytesTransferred / event.totalBytes) * 100).round();
        if (percentComplete == 100) {
          uploadStatus = "Finalizing Video...";
        } else {
          uploadStatus = "Uploading Video $percentComplete%";
        }
        setState(() {});
      });
      await uploadTask.catchError((e) => print(e));
      downloadUrl = await ref.getDownloadURL();
      uploadStatus = "Upload Success";
      setState(() {});
      EventDataService()
          .setReviewStatus(widget.event.id, widget.event.title, widget.event.authorID, widget.event.nearbyZipcodes, widget.event.imageURL, downloadUrl);
    }
  }

  void getVideo() async {
    setState(() {
      vidFile = null;
    });
    File file = await WebblenImagePicker(
      context: context,
      ratioX: 1.0,
      ratioY: 1.0,
    ).retrieveVideoFromLibrary();
    if (file != null) {
      MediaInfo media = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.HighestQuality,
        deleteOrigin: false,
      );
      vidFile = media.file;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    compressProgressSub = VideoCompress.compressProgress$.subscribe((progress) {
      if (progress != 100.0) {
        setState(() {
          uploadStatus = "Compressing Video: ${progress.toStringAsFixed(0)}%";
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    compressProgressSub.unsubscribe();
    VideoCompress.deleteAllCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: WebblenAppBar().basicAppBar("Upload Video", context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            uploadStatus == null
                ? Container()
                : Text(
                    "$uploadStatus",
                    style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            SizedBox(height: 8.0),
            vidFile == null
                ? Text(
                    "No Video Selected",
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  )
                : Text(
                    "${vidFile.path}",
                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
            SizedBox(height: 32.0),
            CustomColorButton(
              text: "Select Video",
              textColor: FlatColors.darkGray,
              backgroundColor: Colors.white,
              width: 200.0,
              height: 45.0,
              onPressed: () => getVideo(),
            ),
            SizedBox(height: 8.0),
            CustomColorButton(
              text: "Upload Video",
              textColor: FlatColors.darkGray,
              backgroundColor: Colors.white,
              width: 200.0,
              height: 45.0,
              onPressed: () => uploadFile(),
            ),
          ],
        ),
      ),
    );
  }
}
