import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/ui/bottom_sheets/calendar_bottom_sheet/calendar_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/confirmation_bottom_sheets/destructive_confirmation_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/content_bottom_sheets/content_options_bottom_sheet/content_options_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/home_filter_bottom_sheet/home_filter_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/purchase_webblen_bottom_sheet/purchase_webblen_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/user_options_bottom_sheets/current_user_options_bottom_sheet/current_user_options_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/user_options_bottom_sheets/user_options_bottom_sheet/user_options_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/video_streaming_bottom_sheets/host/gifters_bottom_sheet.dart';

import 'confirmation_bottom_sheets/new_content_confirmation_bottom_sheet/new_content_confirmation_bottom_sheet.dart';
import 'content_bottom_sheets/add_content_bottom_sheet/add_content_bottom_sheet/add_content_bottom_sheet.dart';
import 'content_bottom_sheets/add_content_bottom_sheet/add_content_successful_bottom_sheet/add_content_successful_bottom_sheet.dart';
import 'content_bottom_sheets/content_author_bottom_sheet/content_author_bottom_sheet.dart';
import 'image_picker_bottom_sheet/image_picker_bottom_sheet.dart';

void setupBottomSheetUI() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = {
    BottomSheetType.addContent: (context, sheetRequest, completer) => AddContentBottomSheet(
          request: sheetRequest,
          completer: completer,
        ),
    BottomSheetType.addContentSuccessful: (context, sheetRequest, completer) => AddContentSuccessfulBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.contentAuthorOptions: (context, sheetRequest, completer) => ContentAuthorBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.contentOptions: (context, sheetRequest, completer) => ContentOptionsBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.displayContentGifters: (context, sheetRequest, completer) => GiftersBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.newContentConfirmation: (context, sheetRequest, completer) =>
        NewContentConfirmationBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.destructiveConfirmation: (context, sheetRequest, completer) =>
        DestructiveConfirmationBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.currentUserOptions: (context, sheetRequest, completer) => CurrentUserOptionsBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.userOptions: (context, sheetRequest, completer) => UserOptionsBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.homeFilter: (context, sheetRequest, completer) => HomeFilterBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.imagePicker: (context, sheetRequest, completer) => ImagePickerBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.calendar: (context, sheetRequest, completer) => CalendarBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.purchaseWBLN: (context, sheetRequest, completer) => PurchaseWebblenBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.eventCreatorOptions: (context, sheetRequest, completer) => CauseCreatorBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.eventOptions: (context, sheetRequest, completer) => CauseBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.streamPublished: (context, sheetRequest, completer) => CausePublishSuccessfulBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.streamCreatorOptions: (context, sheetRequest, completer) => CauseCreatorBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.streamOptions: (context, sheetRequest, completer) => CauseBottomSheet(request: sheetRequest, completer: completer),
  };
  bottomSheetService.setCustomSheetBuilders(builders);
}
