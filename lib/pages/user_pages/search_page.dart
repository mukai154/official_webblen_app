import 'package:flutter/material.dart';
import 'package:webblen/algolia/algolia_search.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_search/search_widgets.dart';

class SearchPage extends StatefulWidget {
  final WebblenUser currentUser;
  final String areaName;

  SearchPage({
    this.currentUser,
    this.areaName,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController textEditingController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSearching = false;
  bool isLoading = true;
  String searchVal = '';
  List<Map<String, dynamic>> allResults = [];
  List<Map<String, dynamic>> eventResults = [];
  List<Map<String, dynamic>> userResults = [];
  String resultType;
  bool searchPerformed = false;
  String searchFilter = '';
//  String cityFilter = '';

  clearSearch() {
    setState(() {
      textEditingController.clear();
      searchVal = '';
      allResults = [];
      searchPerformed = false;
    });
  }

  performSearch() async {
    if (searchVal == '' || searchVal == null) {
      clearSearch();
    } else {
      eventResults = await AlgoliaSearch().queryEvents(searchVal);
      userResults = await AlgoliaSearch().queryUsers(searchVal);
      allResults = [
        eventResults,
        userResults,
      ].expand((x) => x).toList();
      searchPerformed = true;
    }
    setState(() {});
  }

  void transitionToUserDetails(String uid) {
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService().getUserByID(uid).then((user) {
      Navigator.of(context).pop();
      PageTransitionService(context: context, currentUser: widget.currentUser, webblenUser: user).transitionToUserPage();
    });
  }

  void transitionToEventDetails(String eventID) {
    ShowAlertDialogService().showLoadingDialog(context);
    EventDataService().getEvent(eventID).then((event) {
      Navigator.of(context).pop();
      if (event == null) {
        ShowAlertDialogService().showFailureDialog(
          context,
          "Woops! 😬",
          "This Event No Longer Exists",
        );
      } else {
        PageTransitionService(
          context: context,
          currentUser: widget.currentUser,
          eventID: eventID,
          eventIsLive: false,
        ).transitionToEventPage();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //WebblenUserData().transitionFriendsToFollowers();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildSearchField() {
      return Container(
        margin: EdgeInsets.only(
          left: 16,
          top: 16,
          right: 16,
          bottom: 16.0,
        ),
        decoration: BoxDecoration(
          color: FlatColors.textFieldGray,
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: TextFormField(
          controller: textEditingController,
          maxLines: 1,
          textCapitalization: TextCapitalization.none,
          cursorColor: FlatColors.darkGray,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontFamily: 'Helvetica Neue',
            fontWeight: FontWeight.w700,
          ),
          autofocus: false,
          textAlign: TextAlign.left,
          onChanged: (value) {
            searchVal = value.toLowerCase().trim();
            performSearch();
          },
          decoration: InputDecoration(
            //icon: Icon(Icons.search, color: Colors.black54, size: 18.0),
            border: InputBorder.none,
            hintText: "What Are You Looking For?",
            contentPadding: EdgeInsets.fromLTRB(
              12.0,
              8.0,
              8.0,
              8.0,
            ),
          ),
        ),
      );
    }

    Widget searchResults() {
      return Flexible(
          //decoration: new BoxDecoration(border: new Border.all(width: 2.0)),
          //height:double.infinity,
          //fit: FlexFit.loose ,
          child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: allResults.length,
              itemBuilder: (context, index) {
                return SearchResultRow(
                  resultData: allResults[index],
                  tapAction: allResults[index]['resultType'] == 'user'
                      ? () => transitionToUserDetails(allResults[index]['key'])
                      : () => transitionToEventDetails(allResults[index]['key']),
                  addFriendAction: null,
                );
              }));
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0.5,
        title: Fonts().textW700(
          'Search',
          24.0,
          Colors.black,
          TextAlign.center,
        ),
        backgroundColor: Color(0xFFF9F9F9),
        brightness: Brightness.light,
        leading: BackButton(
          color: Colors.black,
        ),
        actions: <Widget>[
          searchPerformed
              ? GestureDetector(
                  onTap: () => clearSearch(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 20.0,
                      right: 8.0,
                    ),
                    child: Fonts().textW700(
                      'Clear',
                      16.0,
                      Colors.black,
                      TextAlign.center,
                    ),
                  ),
                )
              : Container()
        ],
      ),
      body: isSearching
          ? LoadingScreen(
              context: context,
              loadingDescription: 'Searching...',
            )
          : GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Container(
                child: Column(
                  children: <Widget>[
                    _buildSearchField(),
                    //searchTypes(),
                    Container(
                      child: searchResults(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
