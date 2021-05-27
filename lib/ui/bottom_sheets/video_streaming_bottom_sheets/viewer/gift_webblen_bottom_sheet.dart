import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/bottom_sheets/video_streaming_bottom_sheets/viewer/gift_webblen_bottom_sheet_model.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

class GiftWebblenBottomSheet extends StatelessWidget {
  final SheetRequest? request;
  final Function(SheetResponse)? completer;

  const GiftWebblenBottomSheet({
    Key? key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GiftWebblenBottomSheetModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => GiftWebblenBottomSheetModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : Container(
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: model.sheetMode == BottomSheetMode.rewards
                  ? _WebblenGiftView(contentID: request!.customData['contentID'], hostID: request!.customData['hostID'], completer: completer!)
                  : _WebblenRefillView(),
            ),
    );
  }
}

class _WebblenGiftView extends HookViewModelWidget<GiftWebblenBottomSheetModel> {
  final String contentID;
  final String hostID;
  final Function(SheetResponse) completer;
  _WebblenGiftView({required this.contentID, required this.hostID, required this.completer});

  @override
  Widget buildViewModelWidget(BuildContext context, GiftWebblenBottomSheetModel model) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'Gifts',
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Award(
              giftID: 1,
              action: () => model.giftStreamer(contentID: contentID, hostID: hostID, giftID: 1, giftAmount: 0.1, completer: completer),
            ),
            _Award(
              giftID: 2,
              action: () => model.giftStreamer(contentID: contentID, hostID: hostID, giftID: 2, giftAmount: 0.5, completer: completer),
            ),
            _Award(
              giftID: 3,
              action: () => model.giftStreamer(contentID: contentID, hostID: hostID, giftID: 3, giftAmount: 5.000001, completer: completer),
            ),
            _Award(
              giftID: 4,
              action: () => model.giftStreamer(contentID: contentID, hostID: hostID, giftID: 4, giftAmount: 25.000001, completer: completer),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Award(
              giftID: 5,
              action: () => model.giftStreamer(contentID: contentID, hostID: hostID, giftID: 5, giftAmount: 50.000001, completer: completer),
            ),
            _Award(
              giftID: 6,
              action: () => model.giftStreamer(contentID: contentID, hostID: hostID, giftID: 6, giftAmount: 100.000001, completer: completer),
            ),
            _Award(
              giftID: 7,
              action: () => model.giftStreamer(contentID: contentID, hostID: hostID, giftID: 7, giftAmount: 500.000001, completer: completer),
            ),
            _Award(
              giftID: 8,
              action: () => model.giftStreamer(contentID: contentID, hostID: hostID, giftID: 8, giftAmount: 1.000001, completer: completer),
            ),
          ],
        ),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
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
                        model.user.WBLN!.toStringAsFixed(2),
                        style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              child: Text(
                'Get More Webblen',
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
              ),
              onTap: () => model.toggleBottomSheetMode(),
            ),
          ],
        ),
        verticalSpaceMedium,
      ],
    );
  }
}

class _Award extends StatelessWidget {
  final int giftID;
  final VoidCallback action;
  _Award({required this.giftID, required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            child: Image.asset(
              giftID == 1
                  ? 'assets/images/heart_icon.png'
                  : giftID == 2
                      ? 'assets/images/double_heart_icon.png'
                      : giftID == 3
                          ? 'assets/images/confetti_icon.png'
                          : giftID == 4
                              ? 'assets/images/dj_icon.png'
                              : giftID == 5
                                  ? 'assets/images/wolf_icon.png'
                                  : giftID == 6
                                      ? 'assets/images/eagle_icon.png'
                                      : giftID == 7
                                          ? 'assets/images/heart_fire_icon.png'
                                          : 'assets/images/webblen_coin.png',
            ),
          ),
          SizedBox(height: 4),
          Text(
            giftID == 1
                ? 'Love'
                : giftID == 2
                    ? 'More Love'
                    : giftID == 3
                        ? 'Confetti'
                        : giftID == 4
                            ? 'Party'
                            : giftID == 5
                                ? 'Wolf'
                                : giftID == 6
                                    ? 'Eagle'
                                    : giftID == 7
                                        ? 'Much Love'
                                        : 'Webblen',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                giftID == 1
                    ? '0.10'
                    : giftID == 2
                        ? '0.50'
                        : giftID == 3
                            ? '5'
                            : giftID == 4
                                ? '25'
                                : giftID == 5
                                    ? '50'
                                    : giftID == 6
                                        ? '100'
                                        : giftID == 7
                                            ? '500'
                                            : '1',
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
              ),
              SizedBox(width: 4),
              Container(
                height: 15,
                width: 15,
                child: Image.asset(
                  'assets/images/webblen_coin.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebblenRefillView extends HookViewModelWidget<GiftWebblenBottomSheetModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, GiftWebblenBottomSheetModel model) {
    return model.completingPurchase
        ? Center(
            child: CustomCircleProgressIndicator(
              color: appActiveColor(),
              size: 10,
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    child: Row(
                      children: [
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
                                model.user.WBLN!.toStringAsFixed(2),
                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    child: Text(
                      'Refill',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 100,
                  ),
                ],
              ),
              SizedBox(height: 32),
              GridView.count(
                childAspectRatio: 3 / 2,
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 18,
                children: [
                  _RefillItem(
                    itemNum: 1,
                    purchaseProduct: () => model.purchaseProduct('webblen_1'),
                  ),
                  _RefillItem(
                    itemNum: 2,
                    purchaseProduct: () => model.purchaseProduct('webblen_5'),
                  ),
                  _RefillItem(
                    itemNum: 3,
                    purchaseProduct: () => model.purchaseProduct('webblen_25'),
                  ),
                  _RefillItem(
                    itemNum: 4,
                    purchaseProduct: () => model.purchaseProduct('webblen_50'),
                  ),
                  _RefillItem(
                    itemNum: 5,
                    purchaseProduct: () => model.purchaseProduct('webblen_100'),
                  ),
                ],
              ),
              SizedBox(height: 32),
              GestureDetector(
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                onTap: () => model.toggleBottomSheetMode(),
              ),
              verticalSpaceMedium,
            ],
          );
  }
}

class _RefillItem extends StatelessWidget {
  final int itemNum;
  final VoidCallback purchaseProduct;
  _RefillItem({required this.itemNum, required this.purchaseProduct});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: purchaseProduct,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 20,
                  width: 20,
                  child: Image.asset(
                    'assets/images/webblen_coin.png',
                  ),
                ),
                SizedBox(width: 2),
                Text(
                  itemNum == 1
                      ? '1'
                      : itemNum == 2
                          ? '5'
                          : itemNum == 3
                              ? '25'
                              : itemNum == 4
                                  ? '50'
                                  : '100',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              itemNum == 1
                  ? '\$0.99'
                  : itemNum == 2
                      ? '\$4.99'
                      : itemNum == 3
                          ? '\$24.99'
                          : itemNum == 4
                              ? '\$49.99'
                              : '\$99.99',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w300,
              ),
            )
          ],
        ),
      ),
    );
  }
}
