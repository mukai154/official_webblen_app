import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/home/tabs/profile/profile_view_model.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/list_builders/list_events/profile/list_profile_events.dart';
import 'package:webblen/ui/widgets/list_builders/list_live_streams/profile/list_profile_live_streams.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts/profile/list_profile_posts.dart';
import 'package:webblen/ui/widgets/user/follow_stats_row.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, model, child) => Container(
        height: screenHeight(context),
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                _ProfileHead(),
                _ProfileBody(
                  user: model.user,
                ),
                ElevatedButton(
                  onPressed: () => model.generateHotWallet(),
                  child: Text('generate hotwallet'),
                ),
                ElevatedButton(
                  onPressed: () => model.generateEscrowHotWallets(),
                  child: Text('create 100 escrow wallets'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHead extends HookViewModelWidget<ProfileViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ProfileViewModel model) {
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
                onPressed: () => model.showOptions(),
                icon: Icon(
                  FontAwesomeIcons.ellipsisH,
                  color: appIconColor(),
                  size: 20,
                ),
              ),
              IconButton(
                iconSize: 20,
                onPressed: () =>
                    model.customBottomSheetService.showAddContentOptions(),
                icon: Icon(FontAwesomeIcons.plus, color: appIconColor()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileBody extends HookViewModelWidget<ProfileViewModel> {
  final WebblenUser user;
  _ProfileBody({required this.user});

  @override
  Widget buildViewModelWidget(BuildContext context, ProfileViewModel model) {
    var _scrollController = useScrollController();
    var _tabController = useTabController(initialLength: 3);

    return Expanded(
      child: DefaultTabController(
        key: PageStorageKey('profile-tab-bar'),
        length: 4,
        child: NestedScrollView(
          key: PageStorageKey('profile-nested-scroll-key'),
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                key: PageStorageKey('profile-app-bar-key'),
                pinned: true,
                floating: true,
                snap: true,
                forceElevated: innerBoxIsScrolled,
                expandedHeight: ((user.bio != null && user.bio!.isNotEmpty) ||
                        (user.website != null && user.website!.isNotEmpty))
                    ? 250
                    : 200,
                backgroundColor: appBackgroundColor(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    child: Column(
                      children: [
                        _UserDetails(
                          user: user,
                          followerCount: user.followers!.length,
                          followingCount: user.following!.length,
                          viewFollowers: () => model.navigateToFollowers(),
                          viewFollowing: () => model.navigateToFollowing(),
                          viewWebsite: () => model.openWebsite(),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(40),
                  child: WebblenProfileTabBar(
                    //key: PageStorageKey('profile-tab-bar'),
                    tabController: _tabController,
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              //posts
              ListProfilePosts(
                id: model.user.id!,
                isCurrentUser: true,
              ),

              //scheduled streams
              ListProfileLiveStreams(
                id: model.user.id!,
                isCurrentUser: true,
              ),

              //scheduled streams
              ListProfileEvents(
                id: model.user.id!,
                isCurrentUser: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserDetails extends StatelessWidget {
  final WebblenUser user;
  final int followerCount;
  final int followingCount;
  final VoidCallback viewFollowers;
  final VoidCallback viewFollowing;
  final VoidCallback viewWebsite;
  _UserDetails({
    required this.user,
    required this.followerCount,
    required this.followingCount,
    required this.viewFollowers,
    required this.viewFollowing,
    required this.viewWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 16),

          ///USERNAME & PROFILE
          UserProfilePic(
            userPicUrl: user.profilePicURL,
            size: 60,
            isBusy: false,
          ),
          SizedBox(height: 8),
          Text(
            "@${user.username}",
            style: TextStyle(
              color: appFontColor(),
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          verticalSpaceSmall,

          ///FOLOWERS & FOLLOWING
          FollowStatsRow(
            followersLength: followerCount,
            followingLength: followingCount,
            viewFollowersAction: viewFollowers,
            viewFollowingAction: viewFollowing,
          ),
          verticalSpaceSmall,

          ///BIO & WEBSITE
          Container(
            child: Column(
              children: [
                user.bio != null && user.bio!.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(top: 4),
                        child: CustomText(
                          text: user.bio,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: appFontColor(),
                        ),
                      )
                    : Container(),
                user.website != null && user.website!.isNotEmpty
                    ? GestureDetector(
                        onTap: viewWebsite,
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
                                text: user.website,
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
}
