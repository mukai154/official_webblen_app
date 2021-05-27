import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Gifters',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    model.gifters.length >= 1
                        ? LiveStreamGifterContainer(
                            imgURL: model.gifters[0]['userImgURL'],
                            username: model.gifters[0]['username'],
                            amountGifted: model.gifters[0]['totalGiftAmount'],
                          )
                        : Container(width: 100),
                    model.gifters.length >= 2
                        ? Container(
                            width: 100,
                            child: LiveStreamGifterContainer(
                              imgURL: model.gifters[1]['userImgURL'],
                              username: model.gifters[1]['username'],
                              amountGifted: model.gifters[1]['totalGiftAmount'],
                            ),
                          )
                        : Container(width: 100),
                    model.gifters.length >= 3
                        ? Container(
                            width: 100,
                            child: LiveStreamGifterContainer(
                              imgURL: model.gifters[2]['userImgURL'],
                              username: model.gifters[2]['username'],
                              amountGifted: model.gifters[2]['totalGiftAmount'],
                            ),
                          )
                        : Container(width: 100),
                    model.gifters.length >= 4
                        ? Container(
                            width: 100,
                            child: LiveStreamGifterContainer(
                              imgURL: model.gifters[3]['userImgURL'],
                              username: model.gifters[3]['username'],
                              amountGifted: model.gifters[3]['totalGiftAmount'],
                            ),
                          )
                        : Container(width: 100),
                    model.gifters.length >= 5
                        ? Container(
                            width: 100,
                            child: LiveStreamGifterContainer(
                              imgURL: model.gifters[4]['userImgURL'],
                              username: model.gifters[4]['username'],
                              amountGifted: model.gifters[4]['totalGiftAmount'],
                            ),
                          )
                        : Container(width: 100),
                    model.gifters.length >= 6
                        ? Container(
                            width: 100,
                            child: LiveStreamGifterContainer(
                              imgURL: model.gifters[5]['userImgURL'],
                              username: model.gifters[5]['username'],
                              amountGifted: model.gifters[5]['totalGiftAmount'],
                            ),
                          )
                        : Container(width: 100),
                  ],
                ),
                // SizedBox(height: 16),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //
                //   ],
                // ),
              ],
            ),
          ),
          SizedBox(height: 8),
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
                          model.giftPool.totalGiftAmount!.toStringAsFixed(2),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GiftersBottomSheetModel>.reactive(
      onModelReady: (model) => model.initialize(id: request!.customData),
      viewModelBuilder: () => GiftersBottomSheetModel(),
      builder: (context, model, child) => Container(
        color: Colors.black,
        child: model.isBusy
            ? Center(
                child: CustomText(
                  text: "Loading Gifters...",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              )
            : model.gifters.isNotEmpty
                ? giftersView(model)
                : noGiftersView(),
      ),
    );
  }
}
