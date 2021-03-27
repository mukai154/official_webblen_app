import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/users/profile/user_profile_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_linear_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts.dart';
import 'package:webblen/ui/widgets/user/follow_unfollow_button.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

class UserProfileView extends StatefulWidget {
  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> with SingleTickerProviderStateMixin {
  TabController _tabController;

  Widget head(UserProfileViewModel model) {
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
            ],
          ),
        ],
      ),
    );
  }

  Widget userDetails(UserProfileViewModel model) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 16),
          UserProfilePic(
            userPicUrl: model.user.profilePicURL,
            size: 60,
            isBusy: false,
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
          model.isFollowingUser == null
              ? Container()
              : FollowUnfollowButton(isFollowing: model.isFollowingUser, followUnfollowAction: () => model.followUnfollowUser()),
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

  Widget body(UserProfileViewModel model) {
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
                currentUID: model.user.id,
                refreshData: model.refreshPosts,
                postResults: model.postResults,
                pageStorageKey: PageStorageKey('user-posts'),
                showPostOptions: (post) => model.showContentOptions(context: context, content: post),
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
    return ViewModelBuilder<UserProfileViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(context: context, tabController: _tabController),
      viewModelBuilder: () => UserProfileViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: model.user == null ? "" : model.user.username,
          showBackButton: true,
          actionWidget: IconButton(
            onPressed: () => model.showUserOptions(),
            icon: Icon(
              FontAwesomeIcons.ellipsisH,
              size: 16,
              color: appIconColor(),
            ),
          ),
        ),
        body: Container(
          height: screenHeight(context),
          width: screenWidth(context),
          color: appBackgroundColor(),
          child: model.isBusy
              ? Column(
                  children: [
                    CustomLinearProgressIndicator(color: appActiveColor()),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: DefaultTabController(
                        key: null,
                        length: 4,
                        child: NestedScrollView(
                          key: null,
                          controller: model.scrollController,
                          headerSliverBuilder: (context, innerBoxIsScrolled) {
                            return [
                              SliverAppBar(
                                key: null,
                                pinned: true,
                                floating: true,
                                snap: true,
                                forceElevated: innerBoxIsScrolled,
                                expandedHeight: 200,
                                leading: Container(),
                                backgroundColor: appBackgroundColor(),
                                flexibleSpace: FlexibleSpaceBar(
                                  background: Container(
                                    child: Column(
                                      children: [
                                        model.user == null ? Container() : userDetails(model),
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
                          body: model.isBusy ? Container() : body(model),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
