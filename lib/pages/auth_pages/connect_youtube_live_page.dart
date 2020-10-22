import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webblen/firebase/data/platform_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/api/youtube_api.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
//import 'package:http/http.dart' as dart;

class ConnectYoutubeLivePage extends StatefulWidget {
  final WebblenUser currentUser;
  ConnectYoutubeLivePage({this.currentUser});
  @override
  _ConnectYoutubeLivePageState createState() => _ConnectYoutubeLivePageState();
}

class _ConnectYoutubeLivePageState extends State<ConnectYoutubeLivePage> {
  bool isLoading = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String googleIDToken;
  String googleAccessToken;

  String googleApiKey;
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/youtube',
      'https://www.googleapis.com/auth/youtube.readonly',
      'https://www.googleapis.com/auth/youtube.force-ssl',
      'https://www.googleapis.com/auth/youtube.upload',
    ],
  );

  void connectYoutubeAccount() async {
    setState(() {
      isLoading = true;
    });
    ScaffoldState scaffold = scaffoldKey.currentState;
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    if (googleAccount == null) {
      scaffold.showSnackBar(SnackBar(
        content: Text("Cancelled Connecting to Youtube"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
      setState(() {
        isLoading = false;
      });
      return;
    }
    GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
    googleIDToken = googleAuth.idToken;
    googleAccessToken = googleAuth.accessToken;
    WebblenUserData().setGoogleTokens(widget.currentUser.uid, googleIDToken, googleAccessToken);
    DateTime d1 = DateTime.now().add(Duration(hours: 1));
    DateTime d2 = d1.add(Duration(hours: 1));
    await YoutubeAPI().createVideoBroadcast("Test", d1, d2, googleApiKey, googleAccessToken);
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    PlatformDataService().getGoogleApiKey().then((res) {
      googleApiKey = res;
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar("Connect Youtube Account", context),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 32.0),
            CustomColorButton(
              text: 'Connect Youtube Account',
              textColor: Colors.black,
              backgroundColor: Colors.white,
              height: 45.0,
              width: 100.0,
              onPressed: () => connectYoutubeAccount(),
            ),
          ],
        ),
      ),
    );
  }
}
