// import 'package:flutter/material.dart';
// import 'package:stacked/stacked.dart';
// import 'package:webblen/app/app.locator.dart';// import 'package:webblen/constants/app_colors.dart';
// import 'package:webblen/models/webblen_event.dart';
// import 'package:webblen/models/webblen_live_stream.dart';
// import 'package:webblen/models/webblen_post.dart';
// import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
// import 'package:webblen/ui/widgets/common/zero_state_view.dart';
// import 'package:webblen/ui/widgets/events/event_block/event_check_in_block.dart';
// import 'package:webblen/ui/widgets/list_builders/list_content_for_you/list_content_for_you/list_content_for_you_model.dart';
// import 'package:webblen/ui/widgets/posts/post_img_block/post_img_block_view.dart';
// import 'package:webblen/ui/widgets/posts/post_text_block/post_text_block_view.dart';
//
// class ListForYouContent extends StatelessWidget {
//   final Function(WebblenPost) showPostOptions;
//   final Function(WebblenEvent) showEventOptions;
//   final Function(WebblenLiveStream) showStreamOptions;
//
//   ListForYouContent({
//     @required this.showPostOptions,
//     @required this.showEventOptions,
//     @required this.showStreamOptions,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ViewModelBuilder<ListContentForYouModel>.reactive(
//       disposeViewModel: false,
//       initialiseSpecialViewModelsOnce: true,
//       onModelReady: (model) => model.initialize(),
//       viewModelBuilder: () => locator<ListContentForYouModel>(),
//       builder: (context, model, child) => model.isBusy
//           ? Container()
//           : model.dataResults.isEmpty
//               ? ZeroStateView(
//                   scrollController: model.scrollController,
//                   imageAssetName: "mobile_people_group",
//                   imageSize: 200,
//                   header: "You are Not Following Anyone",
//                   subHeader: "Find People and Groups to Follow and Get Involved With",
//                   mainActionButtonTitle: "Explore People & Groups",
//                   mainAction: () {},
//                   secondaryActionButtonTitle: null,
//                   secondaryAction: null,
//                   refreshData: () async {},
//                 )
//               : Container(
//                   height: screenHeight(context),
//                   color: appBackgroundColor(),
//                   child: RefreshIndicator(
//                     onRefresh: model.refreshData,
//                     child: ListView.builder(
//                         controller: model.scrollController,
//                         key: PageStorageKey('home-for-you'),
//                         addAutomaticKeepAlives: true,
//                         shrinkWrap: true,
//                         padding: EdgeInsets.only(
//                           top: 4.0,
//                           bottom: 4.0,
//                         ),
//                         itemCount: model.dataResults.length,
//                         itemBuilder: (context, index) {
//                           if (model.dataResults[index]['contentType'] == 'post') {
//                             WebblenPost post = WebblenPost.fromMap(model.dataResults[index]);
//                             return post.imageURL == null
//                                 ? PostTextBlockView(
//                                     post: post,
//                                     showPostOptions: (post) => showPostOptions(post),
//                                   )
//                                 : PostImgBlockView(
//                                     post: post,
//                                     showPostOptions: (post) => showPostOptions(post),
//                                   );
//                           } else if (model.dataResults[index]['contentType'] == 'event') {
//                             WebblenEvent event = WebblenEvent.fromMap(model.dataResults[index]);
//                             return EventBlockWidget(event: event, showEventOptions: (event) => showEventOptions(event));
//                           }
//
//                           return Container();
//                         }),
//                   ),
//                 ),
//     );
//   }
// }
