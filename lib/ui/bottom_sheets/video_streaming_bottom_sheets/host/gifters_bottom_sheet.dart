import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/live_streams/video_ui/live_stream_gifter_container.dart';

import 'gifters_bottom_sheet_model.dart';

class GiftersBottomSheet extends StatelessWidget {
  final SheetRequest? request;
  final Function(SheetResponse)? completer;

  const GiftersBottomSheet({
    Key? key,
    this.request,
    this.completer,
  }) : super(key: key);

  noGiftersView() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: appBackgroundColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Container(
            child: Text(
              'Top Gifters',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Center(
                child: Text(
                  "Stream Has Not Received Gifts",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  giftersView(GiftersBottomSheetModel model) {
    Map<dynamic, dynamic> giftersMap = model.giftPool == null ? {} : model.giftPool!.gifters!;
    List gifters = giftersMap.values.toList(growable: true);
    if (gifters.length > 1) {
      gifters.sort((a, b) => b['totalGiftAmount'].compareTo(a['totalGiftAmount']));
    }
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'Top Gifters',
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 32),
        Container(
          height: 200,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  gifters.length >= 1
                      ? Container(width: 100)
                      : LiveStreamGifterContainer(
                          imgURL: gifters[0]['userImgURL'],
                          username: gifters[0]['username'],
                          amountGifted: gifters[0]['totalGiftAmount'],
                        ),
                  gifters.length >= 2
                      ? Container(width: 100)
                      : Container(
                          width: 100,
                          child: LiveStreamGifterContainer(
                            imgURL: gifters[1]['userImgURL'],
                            username: gifters[1]['username'],
                            amountGifted: gifters[1]['totalGiftAmount'],
                          ),
                        ),
                  gifters.length >= 3
                      ? Container(width: 100)
                      : Container(
                          width: 100,
                          child: LiveStreamGifterContainer(
                            imgURL: gifters[2]['userImgURL'],
                            username: gifters[2]['username'],
                            amountGifted: gifters[2]['totalGiftAmount'],
                          ),
                        ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  gifters.length >= 4
                      ? Container(width: 100)
                      : Container(
                          width: 100,
                          child: LiveStreamGifterContainer(
                            imgURL: gifters[3]['userImgURL'],
                            username: gifters[3]['username'],
                            amountGifted: gifters[3]['totalGiftAmount'],
                          ),
                        ),
                  gifters.length >= 5
                      ? Container(width: 100)
                      : Container(
                          width: 100,
                          child: LiveStreamGifterContainer(
                            imgURL: gifters[4]['userImgURL'],
                            username: gifters[4]['username'],
                            amountGifted: gifters[4]['totalGiftAmount'],
                          ),
                        ),
                  gifters.length >= 6
                      ? Container(width: 100)
                      : Container(
                          width: 100,
                          child: LiveStreamGifterContainer(
                            imgURL: gifters[5]['userImgURL'],
                            username: gifters[5]['username'],
                            amountGifted: gifters[5]['totalGiftAmount'],
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Total: ",
                        style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 15,
                  width: 15,
                  child: Image.asset(
                    'assets/images/webblen_coin.png',
                  ),
                ),
                SizedBox(width: 4),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        model.giftPool!.totalGiftAmount!.toStringAsFixed(2),
                        style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GiftersBottomSheetModel>.reactive(
      onModelReady: (model) => model.initialize(id: request!.customData),
      viewModelBuilder: () => GiftersBottomSheetModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.giftPoolExists
              ? giftersView(model)
              : noGiftersView(),
    );
  }
}
