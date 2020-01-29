import 'package:flutter/material.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/strings.dart';

class StripeServices {
  connectToStripeAccount(BuildContext context, String uid) async {
    String stripeAuthURL =
        "https://connect.stripe.com/express/oauth/authorize?redirect_uri=https://us-central1-webblen-events.cloudfunctions.net/connectStripeStandardAccount&client_id=${Strings.stripeTestClientID}&state=$uid";
    OpenUrl().launchInWebViewOrVC(
      context,
      stripeAuthURL,
    );
  }
}
