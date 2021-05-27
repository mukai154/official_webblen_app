import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/navigation/tab_bar/custom_tab_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_linear_progress_indicator.dart';
import 'package:webblen/ui/widgets/list_builders/list_events/saved/list_saved_events.dart';
import 'package:webblen/ui/widgets/list_builders/list_live_streams/saved/list_saved_live_streams.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts/saved/list_saved_posts.dart';

import 'saved_content_view_model.dart';

class SavedContentView extends StatefulWidget {
  @override
  _SavedContentViewState createState() => _SavedContentViewState();
}

class _SavedContentViewState extends State<SavedContentView> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SavedContentViewModel>.reactive(
      disposeViewModel: true,
      viewModelBuilder: () => SavedContentViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Saved",
          showBackButton: true,
        ),
        body: Container(
          height: screenHeight(context),
          color: appBackgroundColor(),
          child: SafeArea(
            child: Container(
              child: Column(
                children: [
                  verticalSpaceSmall,
                  WebblenProfileTabBar(
                    tabController: _tabController,
                  ),
                  verticalSpaceSmall,
                  model.isBusy ? CustomLinearProgressIndicator(color: appActiveColor()) : Container(),
                  SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ListSavedPosts(),
                        ListSavedLiveStreams(),
                        ListSavedEvents(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
