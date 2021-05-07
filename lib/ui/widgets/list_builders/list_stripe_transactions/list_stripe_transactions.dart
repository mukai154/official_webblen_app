import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/stripe_transaction.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/zero_state_view.dart';
import 'package:webblen/ui/widgets/wallet/stripe/stripe_transactions/stripe_transaction_block.dart';

import 'list_stripe_transactions_model.dart';

class ListStripeTransactions extends StatelessWidget {
  final String? searchFilter;
  ListStripeTransactions({this.searchFilter});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListStripeTransactionsModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ListStripeTransactionsModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.dataResults.isEmpty
              ? ZeroStateView(
                  scrollController: model.scrollController,
                  imageAssetName: "calendar",
                  imageSize: 200,
                  header: "No Recent Transactions Found",
                  subHeader: "Check back here later once you begin selling tickets, acquiring sponsors, etc",
                  mainActionButtonTitle: "",
                  mainAction: null,
                  secondaryActionButtonTitle: null,
                  secondaryAction: null,
                  refreshData: model.refreshData,
                )
              : Container(
                  color: appBackgroundColor(),
                  child: RefreshIndicator(
                    onRefresh: model.refreshData,
                    child: ListView.builder(
                      controller: model.scrollController,
                      key: PageStorageKey(model.listKey),
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      itemCount: model.dataResults.length + 1,
                      itemBuilder: (context, index) {
                        if (index < model.dataResults.length) {
                          StripeTransaction transaction;
                          transaction = StripeTransaction.fromMap(model.dataResults[index].data()!);
                          return searchFilter != null || searchFilter!.isNotEmpty
                              ? transaction.description!.toLowerCase().contains(searchFilter!)
                                  ? StripeTransactionBlock(
                                      transaction: transaction,
                                    )
                                  : Container()
                              : StripeTransactionBlock(
                                  transaction: transaction,
                                );
                        } else {
                          if (model.moreDataAvailable) {
                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              model.loadAdditionalData();
                            });
                            return Align(
                              alignment: Alignment.center,
                              child: CustomCircleProgressIndicator(size: 10, color: appActiveColor()),
                            );
                          }
                          return Container(
                            height: 500,
                          );
                        }
                      },
                    ),
                  ),
                ),
    );
  }
}
