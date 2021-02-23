enum NotificationType {
  newFollower,
  newPost,
  newEvent,
  editedEvent,
  eventIsLive,
  newStream,
  editedStream,
  streamIsLive,
  postComment,
  postCommentReply,
  webblenSent,
  webblenReceived,
  importantInfo,
}

class NotificationTypeConverter {
  static NotificationType stringToNotificationType(String notificationType) {
    if (notificationType == 'newFollower') {
      return NotificationType.newFollower;
    } else if (notificationType == 'newPost') {
      return NotificationType.newPost;
    } else if (notificationType == 'newEvent') {
      return NotificationType.newEvent;
    } else if (notificationType == 'editedEvent') {
      return NotificationType.editedEvent;
    } else if (notificationType == 'eventIsLive') {
      return NotificationType.eventIsLive;
    } else if (notificationType == 'newStream') {
      return NotificationType.newStream;
    } else if (notificationType == 'editedStream') {
      return NotificationType.editedStream;
    } else if (notificationType == 'streamIsLive') {
      return NotificationType.streamIsLive;
    } else if (notificationType == 'postComment') {
      return NotificationType.postComment;
    } else if (notificationType == 'postCommentReply') {
      return NotificationType.postCommentReply;
    } else if (notificationType == 'webblenSent') {
      return NotificationType.webblenSent;
    } else if (notificationType == 'webblenReceived') {
      return NotificationType.webblenReceived;
    } else {
      return NotificationType.importantInfo;
    }
  }

  static String notificationTypeToString(NotificationType notificationType) {
    if (notificationType == NotificationType.newFollower) {
      return 'newFollower';
    } else if (notificationType == NotificationType.newPost) {
      return 'newPost';
    } else if (notificationType == NotificationType.newEvent) {
      return 'newEvent';
    } else if (notificationType == NotificationType.editedEvent) {
      return 'editedEvent';
    } else if (notificationType == NotificationType.eventIsLive) {
      return 'eventIsLive';
    } else if (notificationType == NotificationType.newStream) {
      return 'newStream';
    } else if (notificationType == NotificationType.editedStream) {
      return 'editedStream';
    } else if (notificationType == NotificationType.streamIsLive) {
      return 'streamIsLive';
    } else if (notificationType == NotificationType.postComment) {
      return 'postComment';
    } else if (notificationType == NotificationType.postCommentReply) {
      return 'postCommentReply';
    } else if (notificationType == NotificationType.webblenSent) {
      return 'webblenSent';
    } else if (notificationType == NotificationType.webblenReceived) {
      return 'webblenReceived';
    } else {
      return 'importantInfo';
    }
  }
}
