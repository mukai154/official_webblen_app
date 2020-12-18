import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/user_widgets/follow_stats_row.dart';
import 'package:webblen/ui/user_widgets/user_profile_pic.dart';
import 'package:webblen/ui/views/home/tabs/profile/profile_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';

class ProfileView extends StatefulWidget {
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

  Widget userDetails(ProfileViewModel model) {
    return model.isBusy
        ? Container(
            child: Column(
              children: [
                SizedBox(height: 16),
                UserProfilePic(
                  userPicUrl: "",
                  size: 60,
                  isBusy: true,
                ),
              ],
            ),
          )
        : Container(
            child: Column(
              children: [
                SizedBox(height: 16),
                UserProfilePic(
                  userPicUrl: model.user.profile_pic,
                  size: 60,
                  isBusy: model.isBusy,
                ),
                SizedBox(height: 8),
                Text(
                  "@${model.user.username}",
                  style: TextStyle(
                    color: appFontColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 8),
                FollowStatsRow(
                  followersLength: model.user.followers.length,
                  followingLength: model.user.following.length,
                  viewFollowersAction: null,
                  viewFollowingAction: null,
                ),
              ],
            ),
          );
  }

  Widget tabBar() {
    return WebblenProfileTabBar(
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
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ProfileViewModel(),
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
                                    userDetails(model),
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