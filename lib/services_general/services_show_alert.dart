import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webblen/widgets_common/common_alert.dart';

class ShowAlertDialogService {
  Future<bool> showAlert(BuildContext context, Widget alertWidget, bool isDismissible) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: isDismissible, // user must tap button!
        builder: (BuildContext context) {
          return alertWidget;
        });
  }

  Future<bool> showSuccessDialog(BuildContext context, String header, String body) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return SuccessDialog(header: header, body: body);
        });
  }

  Future<bool> showFailureDialog(BuildContext context, String header, String body) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return FailureDialog(header: header, body: body);
        });
  }

  Future<bool> showCancelEventDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return CancelEventDialog();
        });
  }

  Future<bool> showInfoDialog(BuildContext context, String header, String body) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return InfoDialog(header: header, body: body);
        });
  }

  Future<bool> showUpdateDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return UpdateAvailableDialog();
        });
  }

  Future<bool> showLoadingDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, //// user must tap button!
        builder: (BuildContext context) {
          return LoadingDialog();
        });
  }

  Future<bool> showLoadingCommunityDialog(BuildContext context, String areaName, String comName) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, //// user must tap button!
        builder: (BuildContext context) {
          return LoadingCommunityDialog(areaName: areaName, comName: comName);
        });
  }

  Future<bool> showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, //// user must tap button!
        builder: (BuildContext context) {
          return LogoutDialog(context: context);
        });
  }

  Future<bool> showCancelDialog(BuildContext context, String header, VoidCallback action) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, //// user must tap button!
        builder: (BuildContext context) {
          return CancelActionDialog(header: header, cancelAction: action);
        });
  }

  Future<bool> showCommunityOptionsDialog(BuildContext context, bool isMember, String communityType, VoidCallback viewMembersAction,
      VoidCallback setComImageAction, VoidCallback addAction, VoidCallback inviteAction, VoidCallback leaveAction, VoidCallback joinAction) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, //// user must tap button!
        builder: (BuildContext context) {
          return CommunityOptionsDialog(
              isMember: isMember,
              communityType: communityType,
              viewMembersAction: viewMembersAction,
              setComImageAction: setComImageAction,
              addAction: addAction,
              inviteAction: inviteAction,
              leaveAction: leaveAction,
              joinAction: joinAction);
        });
  }

  Future<bool> showConfirmationDialog(BuildContext context, String header, String confirmActionTitle, VoidCallback confirmAction, VoidCallback cancelAction) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, //// user must tap button!
        builder: (BuildContext context) {
          return ConfirmationDialog(header: header, confirmActionTitle: confirmActionTitle, confirmAction: confirmAction, cancelAction: cancelAction);
        });
  }

  Future<bool> showDetailedConfirmationDialog(
      BuildContext context, String header, String body, String confirmActionTitle, VoidCallback confirmAction, VoidCallback cancelAction) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, //// user must tap button!
        builder: (BuildContext context) {
          return DetailedConfirmationDialog(
              header: header, body: body, confirmActionTitle: confirmActionTitle, confirmAction: confirmAction, cancelAction: cancelAction);
        });
  }

  Future<bool> showActionSuccessDialog(BuildContext context, String header, String body, VoidCallback action) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, //// user must tap button!
        builder: (BuildContext context) {
          return ActionSuccessDialog(header: header, body: body, action: action);
        });
  }

  Future<bool> showFormWidget(BuildContext context, String header, Widget formWidget, VoidCallback action) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, //// user must tap button!
        builder: (BuildContext context) {
          return FormActionDialog(header: header, formWidget: formWidget, action: action);
        });
  }

  Future<bool> showImageSelectDialog(BuildContext context, VoidCallback imageFromCameraAction, VoidCallback imageFromLibraryAction) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, //// user must tap button!
        builder: (BuildContext context) {
          return AddImageDialog(imageFromCameraAction: imageFromCameraAction, imageFromLibraryAction: imageFromLibraryAction);
        });
  }

  Future<bool> showEventOptionsDialog(
      BuildContext context, VoidCallback viewAttendeesAction, VoidCallback shareEventAction, VoidCallback editAction, VoidCallback deleteEventAction) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, //// user must tap button!
        builder: (BuildContext context) {
          return EventOptionsDialog(
              viewAttendeesAction: viewAttendeesAction, shareEventAction: shareEventAction, editAction: editAction, deleteEventAction: deleteEventAction);
        });
  }

  Future<bool> showAccountQRDialog(BuildContext context, String username, String uid, VoidCallback scanAction) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, //// user must tap button!
        builder: (BuildContext context) {
          return AccountQRDialog(username: username, uid: uid, scanAction: scanAction);
        });
  }

  Future<bool> showScannedAccount(BuildContext context, String username, String uid, VoidCallback addFriendAction) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, //// user must tap button!
        builder: (BuildContext context) {
          return ScannedAccountDialog(username: username, uid: uid, addFriendAction: addFriendAction);
        });
  }

  Future<bool> showCalendarFilterDialog(BuildContext context, String currentFilter, VoidCallback filterToAllEvents, VoidCallback filterToSavedEvents,
      VoidCallback filterToCreatedEvents, VoidCallback filterToReminders) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, //// user must tap button!
        builder: (BuildContext context) {
          return CalendarFilterDialog(
              currentFilter: currentFilter,
              changeFilterToAllEvents: filterToAllEvents,
              changeFilterToSavedEvents: filterToSavedEvents,
              changeFilterToCreatedEvents: filterToCreatedEvents,
              changeFilterToReminders: filterToReminders);
        });
  }

  Future<bool> showCreateEventReminderDialog(BuildContext context, VoidCallback createEvent, VoidCallback createReminder) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, //// user must tap button!
        builder: (BuildContext context) {
          return CreateEventReminderDialog(createEvent: createEvent, createReminder: createReminder);
        });
  }

  Future<bool> showCalendarEventOptions(BuildContext context, VoidCallback edit, VoidCallback delete) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true, //// user must tap button!
        builder: (BuildContext context) {
          return CalendarEventOptionsDialog(editAction: edit, deleteAction: delete);
        });
  }
}
