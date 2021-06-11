import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/ui/widgets/list_builders/list_congregated_content/list_discover_content/list_discover_content.dart';
import 'package:webblen/ui/widgets/list_builders/list_events/home/list_home_events.dart';
import 'package:webblen/ui/widgets/list_builders/list_live_streams/home/list_home_live_streams.dart';
import 'package:webblen/ui/widgets/list_builders/list_posts/home/list_home_posts.dart';

import 'home_feed_model.dart';

class HomeFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeFeedModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => locator<HomeFeedModel>(),
      builder: (context, model, child) => Expanded(
        child: model.contentType == "Posts Only"
            ? ListHomePosts()
            : model.contentType == "Streams Only"
                ? ListHomeLiveStreams()
                : model.contentType == "Events Only"
                    ? ListHomeEvents()
                    : model.contentType == "Posts, Streams, and Events"
                        ? ListDiscoverContent()
                        : Container(),
      ),
    );
  }
}
