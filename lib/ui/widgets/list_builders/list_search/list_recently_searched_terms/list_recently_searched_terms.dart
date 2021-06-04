import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/list_builders/list_search/list_recently_searched_terms/list_recently_searched_terms_model.dart';
import 'package:webblen/ui/widgets/search/search_result_view.dart';

class ListRecentlySearchedTerms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ListRecentlySearchedTermsModel>.reactive(
      viewModelBuilder: () => ListRecentlySearchedTermsModel(),
      builder: (context, model, child) => model.isBusy
          ? Container()
          : model.user.recentSearchTerms == null || model.user.recentSearchTerms!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              'assets/images/search.png',
                              height: 250,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                        ),
                      ),
                      CustomText(
                        text: "No Recent Searches Found",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: appFontColorAlt(),
                      ),
                    ],
                  ),
                )
              : Container(
                  height: screenHeight(context),
                  color: appBackgroundColor(),
                  child: ListView.builder(
                    cacheExtent: 8000,
                    controller: null,
                    key: PageStorageKey(model.listKey),
                    addAutomaticKeepAlives: true,
                    shrinkWrap: true,
                    itemCount: model.user.recentSearchTerms!.length,
                    itemBuilder: (context, index) {
                      return RecentSearchTermView(
                        onSearchTermSelected: () => model.navigateToSearchWithTerm(model.user.recentSearchTerms![index]),
                        searchTerm: model.user.recentSearchTerms![index],
                        displayBottomBorder: true,
                        displayIcon: true,
                      );
                    },
                  ),
                ),
    );
  }
}
