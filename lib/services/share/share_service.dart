import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/dynamic_links.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';

class ShareService {
  copyTicketLink({event}) async {
    Clipboard.setData(ClipboardData(text: event.webAppLink));
  }

  shareContent({WebblenUser user, WebblenPost post, WebblenEvent event, String imgPath, bool copyLink}) async {
    String id;
    String contentType;
    String username;
    String title;
    String description;
    String imgURL;
    String placeholderImgURL = "https://uploads-ssl.webflow.com/5f6e2a062cd638f880f8ce94/5f766e7d35932a5659c8f16f_webclip_img.png";

    if (user != null) {
      id = user.uid;
      contentType = "user";
      username = user.username;
      title = "${user.username}'s Profile";
      description = "View Profile";
      imgURL = user.profile_pic;
    } else if (post != null) {
      id = post.id;
      contentType = "post";
      username = await WebblenUserData().getUsername(post.authorID);
      title = "Post by @$username";
      description = post.body.length > 50 ? post.body.substring(0, 49) + "..." : post.body;
      imgURL = post.imageURL == null ? placeholderImgURL : post.imageURL;
    } else {
      id = event.id;
      contentType = "event";
      username = await WebblenUserData().getUsername(event.authorID);
      title = event.title;
      description = event.desc.length > 50 ? event.desc.substring(0, 49) + "..." : event.desc;
      imgURL = event.imageURL;
    }

    String url = await DynamicLinks().createDynamicLink(
      contentType: contentType,
      id: id,
      title: title,
      description: description,
      imageURL: imgURL,
    );

    if (copyLink) {
      if (event != null && event.hasTickets) {
        Clipboard.setData(ClipboardData(text: event.webAppLink));
      } else {
        Clipboard.setData(ClipboardData(text: url));
      }
    } else {
      if (imgPath != null) {
        Share.shareFiles([imgPath], subject: title, text: description + "\n$url");
      } else {
        Share.share(description + "\n$url", subject: title);
      }
    }
  }
}
