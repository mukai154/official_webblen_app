import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/wallet/user_tickets/user_tickets_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/events/event_ticket_block.dart';

class UserTicketsView extends StatelessWidget {
  Widget ticketList(UserTicketsViewModel model) {
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: model.eventsUserHasTicketsForWithNumOfTickets.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: EventTicketBlock(
            eventDescHeight: 120,
            event: model.eventsUserHasTicketsForWithNumOfTickets[index],
            shareEvent: () => Share.share(
                "https://app.webblen.io/#/event?id=${model.eventsUserHasTicketsForWithNumOfTickets[index].id}"),
            numOfTicsForEvent: model.eventsUserHasTicketsForWithNumOfTickets[
                model.eventsUserHasTicketsForWithNumOfTickets[index]],
            viewEventDetails: null,
            viewEventTickets: () {},
            // () => PageTransitionService(context: context, eventID: events[index].id, currentUser: currentUser)
            //     .transitionToEventTicketsPage(), //() => e.navigateToWalletTickets(e.id),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<UserTicketsViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(context),
      viewModelBuilder: () => UserTicketsViewModel(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Scaffold(
            appBar: CustomAppBar()
                .basicAppBar(title: "My Tickets", showBackButton: true),
            body: model.isBusy
                ? Container(
                    color: appBackgroundColor(),
                    child: Center(
                      child: CustomCircleProgressIndicator(
                        color: appActiveColor(),
                        size: 32,
                      ),
                    ),
                  )
                : model.eventsUserHasTicketsForWithNumOfTickets.isEmpty
                    ? Container(
                        color: appBackgroundColor(),
                        child: Center(
                          child: Text(
                            'You have no Tickets :(',
                          ),
                        ),
                      )
                    : Container(
                        color: appBackgroundColor(),
                        height: screenHeight(context),
                        width: screenWidth(context),
                        child: ticketList(model),
                      ),
          ),
        ),
      ),
    );
  }
}
