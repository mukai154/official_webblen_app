import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:webblen/models/local_ad.dart';
import 'package:webblen/utils/open_url.dart';

class AdTile extends StatelessWidget {
  final LocalAd localAd;

  AdTile({
    this.localAd,
  });

  void openUrl(BuildContext context) {
    OpenUrl().launchInWebViewOrVC(
      context,
      localAd.adURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openUrl(context),
      child: Container(
        width: 200,
        margin: EdgeInsets.symmetric(
          horizontal: 4.0,
          vertical: 8.0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: new CachedNetworkImage(
            imageUrl: localAd.imageURL,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
