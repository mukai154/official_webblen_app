import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/list_builders/list_notifications/list_notifications_model.dart';
import 'package:webblen/ui/widgets/notifications/notification_block/notification_block_widget.dart';

class ListNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListNotificationsModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ListNotificationsModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? ZeroStateView(
                  imageAssetName: 'beach_sun',
                  imageSize: 150,
                  header: "No Recent Activity Found",
                  subHeader: "Check Back Later!",
                  secondaryActionButtonTitle: '',
                  scrollController: null,
                  mainAction: () {},
                  refreshData: () {},
                  mainActionButtonTitle: '',
                  secondaryAction: () {},
                )
              : Container(
                  height: screenHeight(context),
                  color: appBackgroundColor(),
                  child: RefreshIndicator(
                    onRefresh: model.refreshData,
                    backgroundColor: appBackgroundColor(),
                    color: appFontColorAlt(),
                    child: SingleChildScrollView(
                      controller: model.scrollController,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        key: PageStorageKey(model.listKey),
                        addAutomaticKeepAlives: true,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          top: 4.0,
                          bottom: 4.0,
                        ),
                        itemCount: model.dataResults.length + 1,
                        itemBuilder: (context, index) {
                          if (index < model.dataResults.length) {
                            WebblenNotification notification;
                            notification = WebblenNotification.fromMap(model.dataResults[index].data()!);
                            return NotificationBlockWidget(
                              notification: notification,
                            );
                          } else {
                            if (model.moreDataAvailable) {
                              WidgetsBinding.instance!.addPostFrameCallback((_) {
                                model.loadAdditionalData();
                              });
                              return Align(
                                alignment: Alignment.center,
                                child: CustomCircleProgressIndicator(size: 10, color: appActiveColor()),
                              );
                            }
                            return Container();
                          }
                        },
                      ),
                    ),
                  ),
                ),
    );
  }
}
