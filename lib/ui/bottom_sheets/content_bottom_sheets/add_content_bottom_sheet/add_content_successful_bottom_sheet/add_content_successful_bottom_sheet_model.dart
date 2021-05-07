import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/utils/copy_shareable_link.dart';

class AddContentSuccessfulBottomSheetModel extends BaseViewModel {
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  shareContentLink(dynamic content) async {
    late String url;
    if (content is WebblenPost) {
      url = await _dynamicLinkService.createPostLink(authorUsername: "@${_reactiveUserService.user.username}", post: content);
    } else if (content is WebblenEvent) {
      url = await _dynamicLinkService.createEventLink(authorUsername: "@${_reactiveUserService.user.username}", event: content);
    } else if (content is WebblenLiveStream) {
      url = await _dynamicLinkService.createLiveStreamLink(authorUsername: "@${_reactiveUserService.user.username}", stream: content);
    }
    _shareService.shareLink(url);
  }

  copyContentLink(dynamic content) async {
    String? url;
    if (content is WebblenPost) {
      url = await _dynamicLinkService.createPostLink(authorUsername: "@${_reactiveUserService.user.username}", post: content);
    } else if (content is WebblenEvent) {
      url = await _dynamicLinkService.createEventLink(authorUsername: "@${_reactiveUserService.user.username}", event: content);
    } else if (content is WebblenLiveStream) {
      url = await _dynamicLinkService.createLiveStreamLink(authorUsername: "@${_reactiveUserService.user.username}", stream: content);
    }
    copyShareableLink(link: url);
  }
}
