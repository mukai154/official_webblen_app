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
        padding: EdgeInsets.only(left: 8, top: 32, right: 0),
        decoration: BoxDecoration(
          color: appBackgroundColor(),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Expanded(
                child: CalendarCarousel(
                  isScrollable: true,
                  headerMargin: EdgeInsets.symmetric(vertical: 8),
                  headerTextStyle: TextStyle(
                    color: appFontColor(),
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
                  inactiveDaysTextStyle: TextStyle(color: appFontColorAlt()),
                  inactiveWeekendTextStyle: TextStyle(color: appFontColorAlt()),
                  selectedDateTime: request!.data['selectedDate'],
                  minSelectedDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                  onDayPressed: (DateTime date, List<Event> events) => completer!(SheetResponse(data: date)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
