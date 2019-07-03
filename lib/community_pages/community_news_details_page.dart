//import 'package:flutter/material.dart';
//import 'package:webblen/services_general/services_show_alert.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'package:webblen/widgets_dashboard/tile_community_news_content.dart';
//import 'package:webblen/models/community_news.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:webblen/styles/flat_colors.dart';
//import 'package:webblen/widgets_common/common_button.dart';
//import 'package:webblen/animations/transition_animations.dart';
//import 'package:webblen/widgets_common/common_progress.dart';
//import 'package:webblen/firebase_services/user_data.dart';
//
//class CommunityNewsDetailsPage extends StatefulWidget {
//
//  final CommunityNewsPost newsPost;
//  final String currentUID;
//  CommunityNewsDetailsPage({this.newsPost, this.currentUID});
//
//  @override
//  _CommunityNewsDetailsPageState createState() => _CommunityNewsDetailsPageState();
//}
//
//class _CommunityNewsDetailsPageState extends State<CommunityNewsDetailsPage> {
//
//  bool loadingButton = false;
//  bool receivedReward = false;
//
//
//  void returnToDashboard () {
//    Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
//  }
//
//  void transitionToWalletPage (BuildContext context) => Navigator.popAndPushNamed(context, '/wallet');
//
//  Future<Null> _launchInWebViewOrVC(String url) async {
//    if (await canLaunch(url)) {
//      await launch(url, forceSafariVC: true, forceWebView: true, statusBarBrightness: Brightness.light);
//    } else {
//      ShowAlertDialogService().showFailureDialog(context, "Error", "There was an issue launching the site: $url");
//    }
//  }
//
//  viewEvent(String eventTitle, String username){
//    return null;
//  }
//
//  viewShop(){
//    return null;
//  }
//
//  Widget buildNewsCard(CommunityNewsPost newsPost){
//    return CommunityNewsRow(newsPost: newsPost, viewingDetails: true);
//  }
//
//
//  Widget newsActionButton(){
//    Widget actionButton = Container();
//    if (widget.newsPost.contentType == 'url'){
//      actionButton = CustomColorButton(
//                        text: "Visit Site",
//                        textColor: Colors.white,
//                        backgroundColor: FlatColors.darkGray,
//                        height: 45.0,
//                        width: 200.0,
//                        onPressed: () => _launchInWebViewOrVC(widget.newsPost.newsURL),
//                      );
//    } else if (widget.newsPost.contentType == 'guide'){
//
//      actionButton = CustomColorButton(
//                        text: "View Guide",
//                        textColor: Colors.white,
//                        backgroundColor: FlatColors.darkGray,
//                        height: 45.0,
//                        width: 200.0,
//                        onPressed: () => _launchInWebViewOrVC('https://www.webblen.io/faq'),
//                      );
//    } else if (widget.newsPost.contentType == 'tickets'){
//      actionButton = CustomColorButton(
//                        text: "Get Tickets",
//                        textColor: Colors.white,
//                        backgroundColor: FlatColors.darkGray,
//                        height: 45.0,
//                        width: 200.0,
//                        onPressed: () => _launchInWebViewOrVC(widget.newsPost.newsURL),
//                      );
//    } else if (widget.newsPost.contentType == 'shop'){
//      actionButton = CustomColorButton(
//                        text: "Visit Shop",
//                        textColor: Colors.white,
//                        backgroundColor: FlatColors.darkGray,
//                        height: 45.0,
//                        width: 200.0,
//                        onPressed: () => _launchInWebViewOrVC(widget.newsPost.newsURL),
//                      );
//    } else if (widget.newsPost.contentType == 'admobPoints'){
//      actionButton = CustomColorButton(
//                        text: "View Ad",
//                        textColor: Colors.white,
//                        backgroundColor: FlatColors.darkGray,
//                        height: 45.0,
//                        width: 200.0,
//                        onPressed: null,
//                      );
//    }
//    return actionButton;
//  }
//
//  Widget buildBackButton(){
//    return Container(
//        decoration: new BoxDecoration(
//            color: Colors.white70,
//            borderRadius: BorderRadius.circular(25.0),
//            boxShadow: <BoxShadow>[
//              new BoxShadow(
//                color: Colors.black12,
//                blurRadius: 2.0,
//                spreadRadius: 1.0,
//                offset: Offset(0.0, 1.3),
//              ),
//            ]
//        ),
//        margin: new EdgeInsets.symmetric(horizontal: 8.0, vertical: 32.0),
//        child: new IconButton(icon: Icon(FontAwesomeIcons.times, size: 20.0, color: FlatColors.darkGray), onPressed: () => Navigator.of(context).pop())
//    );
//  }
//
//  @override
//  void initState() {
//    super.initState();
////    Ads.init('ca-app-pub-2136415475966451');
////    Ads.video.rewardedListener = (String rewardType, int rewardAmount){
////      UserDataService().updateEventPoints(widget.currentUID, 2).then((result){
////        if (!receivedReward){
////          Navigator.of(context).pop();
////        }
////      });
////    };
//
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        brightness: Brightness.light,
//        elevation: 0.0,
//        backgroundColor: FlatColors.iosOffWhite,
//        leading: BackButton(color: FlatColors.londonSquare),
//      ),
//        body: Container(
//          height: MediaQuery.of(context).size.height,
//          width: MediaQuery.of(context).size.width,
//          padding: EdgeInsets.all(8.0),
////          decoration: BoxDecoration(
////            image: DecorationImage(
////                image: CachedNetworkImageProvider(widget.newsPost.newsImageUrl),
////                fit: BoxFit.cover),
////          ),
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              buildNewsCard(widget.newsPost),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.end,
//                children: <Widget>[
//                 loadingButton
//                     ? CustomCircleProgress(40.0, 40.0, 30.0, 30.0, FlatColors.londonSquare)
//                     : newsActionButton()
//                ],
//              ),
//            ],
//          ),
//        )
//    );
//  }
//}