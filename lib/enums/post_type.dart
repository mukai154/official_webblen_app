enum PostType {
  standardPost,
  eventPost,
  streamPost,
}

class PostTypeConverter {
  static PostType stringToPostType(String postType) {
    if (postType == 'standardPost') {
      return PostType.standardPost;
    } else if (postType == 'eventPost') {
      return PostType.eventPost;
    } else {
      return PostType.streamPost;
    }
  }

  static String postTypeToString(PostType postType) {
    if (postType == PostType.standardPost) {
      return 'standardPost';
    } else if (postType == PostType.eventPost) {
      return 'eventPost';
    } else {
      return 'streamPost';
    }
  }
}
