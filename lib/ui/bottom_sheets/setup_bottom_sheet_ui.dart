import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/ui/bottom_sheets/confirmation_bottom_sheet/destructive_confirmation_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/home_filter_bottom_sheet/home_filter_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/post_bottom_sheets/post_author_bottom_sheet/post_author_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/post_bottom_sheets/post_bottom_sheet/post_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/post_bottom_sheets/post_publish_successful_bottom_sheet/post_publish_successful_bottom_sheet.dart';
import 'package:webblen/ui/bottom_sheets/user_options_bottom_sheets/current_user_options_bottom_sheet/current_user_options_bottom_sheet.dart';

import 'image_picker_bottom_sheet/image_picker_bottom_sheet.dart';

void setupBottomSheetUI() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = {
    BottomSheetType.destructiveConfirmation: (context, sheetRequest, completer) =>
        DestructiveConfirmationBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.homeFilter: (context, sheetRequest, completer) => HomeFilterBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.imagePicker: (context, sheetRequest, completer) => ImagePickerBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.eventPublished: (context, sheetRequest, completer) => CausePublishSuccessfulBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.eventCreatorOptions: (context, sheetRequest, completer) => CauseCreatorBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.eventOptions: (context, sheetRequest, completer) => CauseBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.streamPublished: (context, sheetRequest, completer) => CausePublishSuccessfulBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.streamCreatorOptions: (context, sheetRequest, completer) => CauseCreatorBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.streamOptions: (context, sheetRequest, completer) => CauseBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.postPublished: (context, sheetRequest, completer) => PostSuccessfulBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.postAuthorOptions: (context, sheetRequest, completer) => PostAuthorBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.postOptions: (context, sheetRequest, completer) => PostBottomSheet(request: sheetRequest, completer: completer),
    BottomSheetType.currentUserOptions: (context, sheetRequest, completer) => CurrentUserOptionsBottomSheet(request: sheetRequest, completer: completer),
    // BottomSheetType.userOptions: (context, sheetRequest, completer) => UserOptionsBottomSheet(request: sheetRequest, completer: completer),
  };
  bottomSheetService.setCustomSheetBuilders(builders);
}
