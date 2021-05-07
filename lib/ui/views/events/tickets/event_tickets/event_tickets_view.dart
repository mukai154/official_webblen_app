import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

import 'event_tickets_view_model.dart';

class EventTicketsView extends StatelessWidget {
  final String? id;
  EventTicketsView(@PathParam() this.id);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EventTicketsViewModel>.reactive(
      onModelReady: (model) => model.initialize(eventID: id!),
      viewModelBuilder: () => EventTicketsViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: 'Tickets',
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
              : Align(
                  alignment: Alignment.topCenter,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            SizedBox(height: 32.0),
                            model.event.isValid()
                                ? _EventTicketsHead()
                                : Container(
                                    child: Center(
                                      child: CustomText(
                                        text: "There was an issue loading your tickets for this event.\nPlease Contact "
                                            "team@webblen.com for support",
                                        textAlign: TextAlign.center,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: appFontColor(),
                                      ),
                                    ),
                                  ),
                            _EventTicketsList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _EventTicketsHead extends HookViewModelWidget<EventTicketsViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, EventTicketsViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 16.0,
          ),
          GestureDetector(
            onTap: () => model.customNavigationService.navigateToEventView(model.event.id!),
            child: CustomText(
              text: model.event.title,
              textAlign: TextAlign.center,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: appFontColor(),
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomText(
                text: "hosted by ",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: appFontColor(),
              ),
              CustomTextButton(
                onTap: () => model.customNavigationService.navigateToUserView(model.event.authorID!),
                text: "@${model.host!.username}",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: appActiveColor(),
              ),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                FontAwesomeIcons.mapMarkerAlt,
                size: 14.0,
                color: Colors.black38,
              ),
              SizedBox(width: 4.0),
              CustomText(
                text: "${model.event.city}, ${model.event.province}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.left,
                color: appFontColorAlt(),
              ),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          CustomText(
            text: "${model.event.startDate} | ${model.event.startTime}",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
            color: appFontColorAlt(),
          ),
          SizedBox(
            height: 16.0,
          ),
        ],
      ),
    );
  }
}

class _EventTicketsList extends HookViewModelWidget<EventTicketsViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, EventTicketsViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          verticalSpaceMedium,
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: model.tickets.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.only(top: 12.0),
                child: GestureDetector(
                  onTap: () => model.customNavigationService.navigateToTicketView(model.tickets[index].id!),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CustomText(
                          text: model.ticketDistro!.validTicketIDs!.contains(model.tickets[index].id)
                              ? "${model.tickets[index].name}"
                              : "${model.tickets[index].name} (Used)",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: model.ticketDistro!.validTicketIDs!.contains(model.tickets[index].id) ? Colors.blueAccent : appFontColorAlt(),
                        ),
                        CustomText(
                          text: "Ticket ID: ${model.tickets[index].id}",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: appFontColorAlt(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
