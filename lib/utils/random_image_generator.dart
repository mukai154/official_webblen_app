import 'dart:math';

String getRandomImageURL() {
  int num = Random().nextInt(9);
  String? imgURL;
  if (num == 0) {
    imgURL =
        "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2FScreen%20Shot%202021-04-19%20at%2010.48.49%20AM.png?alt=media&token=0b3751f5-8981-4a21-b28b-dd1896e1fe50";
  } else if (num == 1) {
    imgURL =
        "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2FScreen%20Shot%202021-04-19%20at%2010.49.05%20AM.png?alt=media&token=3f6ed970-44ff-4265-8e3a-d7165e38bc07";
  } else if (num == 2) {
    imgURL =
        "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2FScreen%20Shot%202021-04-19%20at%2010.49.32%20AM.png?alt=media&token=c22dfe15-0a89-4382-acd5-23bf4bca922a";
  } else if (num == 3) {
    imgURL =
        "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2FScreen%20Shot%202021-04-19%20at%2010.49.43%20AM.png?alt=media&token=5d8846aa-3dc2-4c65-877f-98213b0fdec4";
  } else if (num == 4) {
    imgURL =
        "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2FScreen%20Shot%202021-04-19%20at%2010.49.55%20AM.png?alt=media&token=a1509d44-e68d-47d8-bb74-ddc955cae771";
  } else if (num == 5) {
    imgURL =
        "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2FScreen%20Shot%202021-04-19%20at%2010.50.20%20AM.png?alt=media&token=c99ef0f6-1252-4fe4-b7ad-b2f9022b9ddc";
  } else if (num == 6) {
    imgURL =
        "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2Fcage.jpeg?alt=media&token=740dd64e-d169-4fb2-ae77-c26de524e223";
  } else if (num == 7) {
    imgURL =
        "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2Fcage.jpeg?alt=media&token=740dd64e-d169-4fb2-ae77-c26de524e223";
  } else {
    imgURL = "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/user_placeholder_imgs%2Fmurray"
        ".jpeg?alt=media&token=9435e75f-ea94-43bb-a3ca-571429ff651b";
  }
  return imgURL;
}
