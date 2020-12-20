import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/notifications/notification_row.dart';

import 'messages_view_model.dart';

class MessagesView extends StatelessWidget {
  final WebblenUser user;
  MessagesView({this.user});

  Widget head(MessagesViewModel model) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Messages",
            style: TextStyle(
              color: appFontColor(),
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget listMessages(ScrollController controller, MessagesViewModel model) {
    return Expanded(
      child: model.isBusy
          ? Center(child: CustomCircleProgressIndicator(color: appActiveColor(), size: 30))
          : LiquidPullToRefresh(
              color: appActiveColor(),
              onRefresh: model.refreshData,
              child: ListView.builder(
                key: PageStorageKey('messages'),
                addAutomaticKeepAlives: true,
                controller: controller,
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  top: 4.0,
                  bottom: 4.0,
                ),
                itemCount: model.messageResults.length,
                itemBuilder: (context, index) {
                  return NotificationRow(
                    onTap: null,
                    header: model.messageResults[index]['notificationTitle'],
                    subHeader: model.messageResults[index]['notificationDescription'],
                    notifType: model.messageResults[index]['notificationType'],
                  );
                },
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MessagesViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      fireOnModelReadyOnce: true,
      onModelReady: (model) => model.initialize(user.uid),
      viewModelBuilder: () => locator<MessagesViewModel>(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                head(model),
                listMessages(model.messagesScrollController, model),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
