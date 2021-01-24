import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/list_builders/list_notifications.dart';

import 'notifications_view_model.dart';

class NotificationsView extends StatelessWidget {
  Widget head(NotificationsViewModel model) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => model.navigateBack(),
                icon: Icon(FontAwesomeIcons.angleLeft, color: appFontColor(), size: 24),
              ),
              Text(
                "Activity",
                style: TextStyle(
                  color: appFontColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget listNotifications(NotificationsViewModel model) {
    return Expanded(
      child: model.notifResults.isEmpty && !model.isReloading
          ? Center(
              child: ZeroStateView(
                imageAssetName: 'coding',
                header: "No Recent Activity Found",
                subHeader: "Check Back Later!",
              ),
            )
          : ListNotifications(
              refreshData: model.refreshData,
              data: model.notifResults,
              pageStorageKey: PageStorageKey('user-notifications'),
              scrollController: model.notificationsScrollController,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationsViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      fireOnModelReadyOnce: true,
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => NotificationsViewModel(),
      builder: (context, model, child) => Scaffold(
        body: Container(
          height: screenHeight(context),
          color: appBackgroundColor(),
          child: SafeArea(
            child: Container(
              child: Column(
                children: [
                  head(model),
                  listNotifications(model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
