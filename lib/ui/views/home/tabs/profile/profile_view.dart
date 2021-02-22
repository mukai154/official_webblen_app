import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/views/home/tabs/profile/profile_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts.dart';
import 'package:webblen/ui/widgets/user/follow_stats_row.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

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
          Row(
            children: [
              IconButton(
                onPressed: () => model.showUserOptions(),
                icon: Icon(
                  FontAwesomeIcons.ellipsisH,
                  color: appIconColor(),
                  size: 20,
                ),
              ),
              IconButton(
                iconSize: 20,
                onPressed: () => model.showAddContentOptions(),
                icon: Icon(FontAwesomeIcons.plus, color: appIconColor()),
              ),
            ],
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
            userPicUrl: widget.user.profilePicURL,
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

  Widget body(ProfileViewModel model) {
    return TabBarView(
      controller: _tabController,
      children: [
        //posts
        model.postResults.isEmpty && !model.isBusy
            ? ZeroStateView(
                imageAssetName: "umbrella_chair",
                imageSize: 200,
                header: "You Have No Posts",
                subHeader: "Create a New Post to Share with the Community",
                mainActionButtonTitle: "Create Post",
                mainAction: () {},
                secondaryActionButtonTitle: null,
                secondaryAction: null,
                refreshData: model.refreshPosts,
              )
            : ListPosts(
                currentUID: widget.user.id,
                refreshData: model.refreshPosts,
                postResults: model.postResults,
                pageStorageKey: PageStorageKey('profile-posts'),
                showPostOptions: (post) => model.showPostOptions(context: context, post: post),
              ),

        //scheduled streams
        ZeroStateView(
          imageAssetName: "video_phone",
          imageSize: 200,
          header: "You Have Not Scheduled Any Streams",
          subHeader: "Find Your Audience and Create a Stream",
          mainActionButtonTitle: "Create Stream",
          mainAction: () {},
          secondaryActionButtonTitle: null,
          secondaryAction: null,
          refreshData: () async {},
        ),
        ZeroStateView(
          imageAssetName: "calendar",
          imageSize: 200,
          header: "You Have Not Scheduled Any Events",
          subHeader: "Create an Event for the Community",
          mainActionButtonTitle: "Create Event",
          mainAction: () {},
          secondaryActionButtonTitle: null,
          secondaryAction: null,
          refreshData: () async {},
          scrollController: null,
        ),
        ZeroStateView(
          imageAssetName: null,
          header: "You Have No Recent Activity",
          subHeader: "Get Involved in Your Community to Change That!",
          mainActionButtonTitle: null,
          mainAction: null,
          secondaryActionButtonTitle: null,
          secondaryAction: null,
          refreshData: () async {},
        ),
        // ZeroStateView(
        //   imageAssetName: null,
        //   header: "No Posts Found",
        //   subHeader: "Posts You Save Will Show Up Here",
        //   mainActionButtonTitle: null,
        //   mainAction: null,
        //   secondaryActionButtonTitle: null,
        //   secondaryAction: null,
        //   refreshData: () async {},
        // ),
        // ZeroStateView(
        //   imageAssetName: null,
        //   header: "No Streams Found",
        //   subHeader: "Streams You Save Will Show Up Here",
        //   mainActionButtonTitle: null,
        //   mainAction: null,
        //   secondaryActionButtonTitle: null,
        //   secondaryAction: null,
        //   refreshData: () async {},
        // ),
        // ZeroStateView(
        //   imageAssetName: null,
        //   header: "No Events Found",
        //   subHeader: "Events You Save Will Show Up Here",
        //   mainActionButtonTitle: null,
        //   mainAction: null,
        //   secondaryActionButtonTitle: null,
        //   secondaryAction: null,
        //   refreshData: () async {},
        // ),
      ],
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
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(context: context, tabController: _tabController, currentUser: widget.user),
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
                      key: PageStorageKey('profile-nested-scroll-key'),
                      controller: model.scrollController,
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            key: PageStorageKey('profile-app-bar-key'),
                            pinned: true,
                            floating: true,
                            forceElevated: innerBoxIsScrolled,
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
                      body: body(model),
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
