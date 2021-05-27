import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/earnings/usd_balance_history/usd_balance_history_view_model.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/list_builders/list_stripe_transactions/list_stripe_transactions.dart';
import 'package:webblen/ui/widgets/search/search_field.dart';

class USDBalanceHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<USDBalanceHistoryViewModel>.reactive(
      viewModelBuilder: () => USDBalanceHistoryViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "My Tickets",
          showBackButton: true,
        ),
        body: Container(
          height: screenHeight(context),
          color: appBackgroundColor(),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  constraints: BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomText(
                        text: "USD Balance History",
                        textAlign: TextAlign.left,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appFontColor(),
                      ),
                      SizedBox(height: 4),
                      _SearchBar(),
                      SizedBox(height: 4),
                      Container(
                        height: screenHeight(context),
                        child: ListStripeTransactions(searchFilter: model.searchTerm),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends HookViewModelWidget<USDBalanceHistoryViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, USDBalanceHistoryViewModel model) {
    final searchTerm = useTextEditingController();
    return GeneralSearchField(
      textEditingController: searchTerm,
      onChanged: (val) {
        searchTerm.selection = TextSelection.fromPosition(TextPosition(offset: searchTerm.text.length));
        model.updateSearchTerm(val);
      },
      onFieldSubmitted: (val) {},
      autoFocus: false,
    );
  }
}
