import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/users/profile/user_profile_view_model.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_linear_progress_indicator.dart';
import 'package:webblen/ui/widgets/list_builders/list_events/profile/list_profile_events.dart';
import 'package:webblen/ui/widgets/list_builders/list_live_streams/profile/list_profile_live_streams.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts/profile/list_profile_posts.dart';
import 'package:webblen/ui/widgets/user/follow_unfollow_button.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

class UserProfileView extends StatefulWidget {
  final String? id;
  UserProfileView(@PathParam() this.id);
  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> with SingleTickerProviderStateMixin {
  TabController? _tabController;

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
            userPicUrl: model.user!.profilePicURL,
            size: 60,
            isBusy: false,
          ),
          SizedBox(height: 8),
          Text(
            "@${model.user!.username}",
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

          ///BIO & WEBSITE
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 12),
            child: Column(
              children: [
                model.user!.bio != null && model.user!.bio!.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(top: 4),
                        child: CustomText(
                          text: model.user!.bio!,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: appFontColor(),
                        ),
                      )
                    : Container(),
                model.user!.website != null && model.user!.website!.isNotEmpty
                    ? GestureDetector(
                        onTap: () => model.viewWebsite(),
                        child: Container(
                          margin: EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesomeIcons.link,
                                size: 12,
                                color: appFontColor(),
                              ),
                              horizontalSpaceTiny,
                              CustomText(
                                text: model.user!.website,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: appFontColor(),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
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

  Widget body(UserProfileViewModel model) {
    return TabBarView(
      controller: _tabController,
      children: [
        //posts
        ListProfilePosts(
          id: model.user!.id!,
          isCurrentUser: false,
        ),

        //scheduled streams
        ListProfileLiveStreams(
          id: model.user!.id!,
          isCurrentUser: false,
        ),

        //scheduled streams
        ListProfileEvents(
          id: model.user!.id!,
          isCurrentUser: false,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, //4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserProfileViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(id: widget.id),
      viewModelBuilder: () => UserProfileViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: model.user == null ? "" : model.user!.username!,
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
                                expandedHeight: ((model.user!.bio != null && model.user!.bio!.isNotEmpty) ||
                                        (model.user!.website != null && model.user!.website!.isNotEmpty))
                                    ? 250
                                    : 200,
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
