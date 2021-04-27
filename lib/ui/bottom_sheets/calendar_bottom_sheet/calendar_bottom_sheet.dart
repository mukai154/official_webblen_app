import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/bottom_sheets/calendar_bottom_sheet/calendar_bottom_sheet_model.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class CalendarBottomSheet extends StatelessWidget {
  final SheetRequest? request;
  final Function(SheetResponse)? completer;

  const CalendarBottomSheet({
    Key? key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CalendarBottomSheetModel>.reactive(
      viewModelBuilder: () => CalendarBottomSheetModel(),
      builder: (context, model, child) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: appBackgroundColor(),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomText(
                text: request!.title,
                textAlign: TextAlign.center,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appFontColor(),
              ),
              CalendarCarousel(
                isScrollable: true,
                width: 300,
                height: 370,
                headerTextStyle: TextStyle(
                  color: appFontColor(),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
                daysTextStyle: TextStyle(color: appFontColor()),
                iconColor: appIconColor(),
                todayButtonColor: appShadowColor(),
                todayTextStyle: TextStyle(color: appFontColor()),
                weekdayTextStyle: TextStyle(color: appFontColor()),
                selectedDayTextStyle: TextStyle(color: Colors.white),
                selectedDayButtonColor: appActiveColor(),
                weekendTextStyle: TextStyle(
                  color: appSavedContentColor(),
                ),
                selectedDateTime: request!.customData['selectedDate'],
                minSelectedDate: request!.customData['minSelectedDate'],
                onDayPressed: (DateTime date, List<Event> events) => completer!(SheetResponse(responseData: date)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
