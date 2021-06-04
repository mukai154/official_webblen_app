import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/events/event_ticket_block/event_ticket_block_view.dart';
import 'package:webblen/ui/widgets/search/search_field.dart';

import 'my_tickets_view_model.dart';

class MyTicketsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MyTicketsViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => MyTicketsViewModel(),
      builder: (context, model, child) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: CustomAppBar().basicAppBar(
            title: "My Tickets",
            showBackButton: true,
          ),
          body: Container(
            height: screenHeight(context),
            color: appBackgroundColor(),
            child: model.isBusy
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Center(
                          child: CustomCircleProgressIndicator(
                            size: 10,
                            color: appActiveColor(),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _SearchBar(),
                      Expanded(
                        child: _TicketsList(),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends HookViewModelWidget<MyTicketsViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, MyTicketsViewModel model) {
    final searchTerm = useTextEditingController();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: GeneralSearchField(
        textEditingController: searchTerm,
        onChanged: (val) {
          searchTerm.selection = TextSelection.fromPosition(TextPosition(offset: searchTerm.text.length));
          model.updateSearchTerm(val);
        },
        onFieldSubmitted: (val) {},
        autoFocus: false,
      ),
    );
  }
}

class _TicketsList extends HookViewModelWidget<MyTicketsViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, MyTicketsViewModel model) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      child: model.loadedEvents.isEmpty
          ? CustomText(
              text: "No Tickets Found in Your Wallet\nIf this is a mistake, please contact team@webblen.com",
              textAlign: TextAlign.center,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: appFontColorAlt(),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: model.loadedEvents.length,
              itemBuilder: (BuildContext context, int index) {
                if (model.searchTerm.isNotEmpty) {
                  if (model.loadedEvents[index]['eventTitle'].toLowerCase().contains(model.searchTerm)) {
                    return EventTicketBlock(
                      eventTitle: model.loadedEvents[index]['eventTitle'],
                      eventAddress: model.loadedEvents[index]['eventAddress'],
                      eventStartDate: model.loadedEvents[index]['eventStartDate'],
                      eventStartTime: model.loadedEvents[index]['eventStartTime'],
                      eventEndTime: model.loadedEvents[index]['eventEndTime'],
                      eventTimezone: model.loadedEvents[index]['eventTimezone'],
                      numOfTicsForEvent: model.ticsPerEvent[model.loadedEvents[index]['id']],
                      viewEventTickets: () => model.customNavigationService.navigateToEventTickets(model.loadedEvents[index]['id']),
                    );
                  } else {
                    return Container();
                  }
                }
                return EventTicketBlock(
                  eventTitle: model.loadedEvents[index]['eventTitle'],
                  eventAddress: model.loadedEvents[index]['eventAddress'],
                  eventStartDate: model.loadedEvents[index]['eventStartDate'],
                  eventStartTime: model.loadedEvents[index]['eventStartTime'],
                  eventEndTime: model.loadedEvents[index]['eventEndTime'],
                  eventTimezone: model.loadedEvents[index]['eventTimezone'],
                  numOfTicsForEvent: model.ticsPerEvent[model.loadedEvents[index]['id']],
                  viewEventTickets: () => model.customNavigationService.navigateToEventTickets(model.loadedEvents[index]['id']),
                );
              },
            ),
    );
  }
}
