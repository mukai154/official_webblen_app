import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/user_widgets/follow_stats_row.dart';
import 'package:webblen/ui/user_widgets/user_profile_pic.dart';
import 'package:webblen/ui/views/home/tabs/profile/profile_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';

class ProfileView extends StatefulWidget {
  final WebblenUser user;
  ProfileView({this.user});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with SingleTickerProviderStateMixin {
  TabController _tabController;

  Widget head(ProfileViewModel model) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Profile",
            style: TextStyle(
              color: appFontColor(),
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          IconButton(
            onPressed: () => model.navigateToSettingsPage(),
            icon: Icon(FontAwesomeIcons.cog, color: appIconColor(), size: 20),
          ),
        ],
      ),
    );
  }

  Widget userDetails() {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 16),
          UserProfilePic(
            userPicUrl: widget.user.profile_pic,
            size: 60,
            isBusy: false,
          ),
          SizedBox(height: 8),
          Text(
            "@${widget.user.username}",
            style: TextStyle(
              color: appFontColor(),
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 8),
          FollowStatsRow(
            followersLength: widget.user.followers.length,
            followingLength: widget.user.following.length,
            viewFollowersAction: null,
            viewFollowingAction: null,
          ),
        ],
      ),
    );
  }

  Widget tabBar() {
    return WebblenProfileTabBar(
      //key: PageStorageKey('profile-tab-bar'),
      tabController: _tabController,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      // onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => locator<ProfileViewModel>(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                head(model),
                Expanded(
                  child: DefaultTabController(
                    key: PageStorageKey('profile-tab-bar'),
                    length: 4,
                    child: NestedScrollView(
                      headerSliverBuilder: (context, value) {
                        return [
                          SliverAppBar(
                            pinned: true,
                            floating: true,
                            expandedHeight: 200,
                            backgroundColor: appBackgroundColor(),
                            flexibleSpace: FlexibleSpaceBar(
                              background: Container(
                                child: Column(
                                  children: [
                                    widget.user == null ? Container() : userDetails(),
                                  ],
                                ),
                              ),
                            ),
                            bottom: PreferredSize(
                              preferredSize: Size.fromHeight(40),
                              child: tabBar(),
                            ),
                          ),
                        ];
                      },
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          Container(),
                          Container(),
                          Container(),
                          Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
