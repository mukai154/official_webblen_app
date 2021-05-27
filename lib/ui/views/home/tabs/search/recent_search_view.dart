import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/list_builders/list_search/list_recently_searched_terms/list_recently_searched_terms.dart';
import 'package:webblen/ui/widgets/search/search_field.dart';

import 'recent_search_view_model.dart';

class RecentSearchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RecentSearchViewModel>.reactive(
      disposeViewModel: false,
      fireOnModelReadyOnce: true,
      initialiseSpecialViewModelsOnce: true,
      viewModelBuilder: () => locator<RecentSearchViewModel>(),
      builder: (context, model, child) => Container(
        height: screenHeight(context),
        color: appBackgroundColor(),
        child: SafeArea(
          child: Column(
            children: [
              _Head(),
              verticalSpaceSmall,
              Expanded(
                child: Material(
                  child: Hero(
                    tag: 'recent-searches',
                    child: Container(
                      color: appBackgroundColor(),
                      child: ListRecentlySearchedTerms(),
                    ),
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

class _Head extends HookViewModelWidget<RecentSearchViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, RecentSearchViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SearchField(
            heroTag: 'search',
            onTap: () => model.navigateToSearchView(),
            enabled: false,
            textEditingController: null,
            onFieldSubmitted: (val) {},
            onChanged: (val) {},
            autoFocus: false,
          ),
          IconButton(
            onPressed: () => model.customBottomSheetService.showAddContentOptions(),
            icon: Icon(FontAwesomeIcons.plus, color: appIconColor(), size: 20),
          ),
        ],
      ),
    );
  }
}
