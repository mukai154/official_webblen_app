import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/ui/bottom_sheets/purchase_webblen_bottom_sheet/purchase_webblen_bottom_sheet_model.dart';

class PurchaseWebblenBottomSheet extends StatelessWidget {
  final SheetRequest? request;
  final Function(SheetResponse)? completer;

  const PurchaseWebblenBottomSheet({
    Key? key,
    this.request,
    this.completer,
  }) : super(key: key);

  Widget _gridItem({int? itemNum, String? prodID, PurchaseWebblenBottomSheetModel? model}) {
    return GestureDetector(
      onTap: () => model!.purchaseProduct(prodID!),
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

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PurchaseWebblenBottomSheetModel>.reactive(
      viewModelBuilder: () => PurchaseWebblenBottomSheetModel(),
      builder: (context, model, child) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        height: 400,
        child: Column(
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
                              model.webblenBaseViewModel!.user!.WBLN!.toStringAsFixed(2),
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
                _gridItem(itemNum: 1, prodID: 'webblen_1', model: model),
                _gridItem(itemNum: 2, prodID: 'webblen_5', model: model),
                _gridItem(itemNum: 3, prodID: 'webblen_25', model: model),
                _gridItem(itemNum: 4, prodID: 'webblen_50', model: model),
                _gridItem(itemNum: 5, prodID: 'webblen_100', model: model),
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
              onTap: () => completer!(SheetResponse(responseData: "back")),
            ),
          ],
        ),
      ),
    );
  }
}
