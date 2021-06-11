import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

import 'home_filter_bottom_sheet_model.dart';

class HomeFilterBottomSheet extends HookWidget {
  final SheetRequest? request;
  final Function(SheetResponse)? completer;

  const HomeFilterBottomSheet({
    Key? key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final location = useTextEditingController();
    final tag = useTextEditingController();

    return ViewModelBuilder<HomeFilterBottomSheetModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => HomeFilterBottomSheetModel(),
      builder: (context, model, child) => Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: appBackgroundColor(),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 35,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Preferences",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: appFontColor(),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: CustomButton(
                          text: "Apply",
                          textSize: 12,
                          height: 26,
                          width: 125,
                          onPressed: () {
                            model.updatePreferences();
                            completer!(SheetResponse());
                          },
                          backgroundColor: appActiveColor(),
                          textColor: Colors.white,
                          elevation: 2,
                          isBusy: model.updatingData,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Feed Type:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: appFontColorAlt(),
                  ),
                ),
                SizedBox(height: 4),
                TextFieldContainer(
                  height: 38,
                  child: DropdownButton(
                    isExpanded: true,
                    underline: Container(),
                    value: model.tempContentType,
                    items: model.contentTypeList.map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (dynamic val) => model.updateContentType(val),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Sort By:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: appFontColorAlt(),
                  ),
                ),
                SizedBox(height: 4),
                TextFieldContainer(
                  height: 38,
                  child: DropdownButton(
                    isExpanded: true,
                    underline: Container(),
                    value: model.tempSortByFilter,
                    items: model.sortByList.map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (dynamic val) => model.updateSortByFilter(val),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Location:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: appFontColorAlt(),
                  ),
                ),
                SizedBox(height: 4),
                TextFieldContainer(
                  child: TypeAheadField(
                    hideOnEmpty: true,
                    hideOnLoading: true,
                    direction: AxisDirection.up,
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: location,
                      cursorColor: appCursorColor(),
                      decoration: InputDecoration(
                        hintText: model.tempCityName.isEmpty ? "Search Location" : model.tempCityName,
                        border: InputBorder.none,
                      ),
                      autofocus: false,
                    ),
                    suggestionsCallback: (searchTerm) async {
                      if (searchTerm.trim().isNotEmpty) {
                        Map<String, dynamic> res = await model.googlePlacesService.googleSearchAutoComplete(key: model.googleAPIKey, input: searchTerm);
                        model.setPlacesSearchResults(res);
                        return model.placeSearchResults.keys.toList();
                      }
                      return [];
                    },
                    itemBuilder: (context, dynamic place) {
                      return ListTile(
                        title: Text(
                          place,
                          style: TextStyle(color: appFontColor(), fontSize: 14.0, fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                    onSuggestionSelected: (dynamic val) {
                      location.text = val;
                      model.getPlaceDetails(val);
                    },
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => model.clearLocationFilter(),
                  child: Text(
                    "Remove Location Filter",
                    style: TextStyle(
                      color: appTextButtonColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Filter By Tag:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: appFontColorAlt(),
                  ),
                ),
                SizedBox(height: 4),
                TextFieldContainer(
                  child: TypeAheadField(
                    hideOnLoading: true,
                    noItemsFoundBuilder: (BuildContext context) {
                      return Text(
                        'No Results Found',
                        style: TextStyle(color: appFontColorAlt(), fontSize: 14.0, fontWeight: FontWeight.w500),
                      );
                    },
                    direction: AxisDirection.up,
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: tag,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: model.tempTagFilter.isEmpty ? "Search for Tag" : model.tempTagFilter,
                        border: InputBorder.none,
                      ),
                      autofocus: false,
                    ),
                    suggestionsCallback: (searchTerm) async {
                      return await model.algoliaSearchService.queryTags(searchTerm);
                    },
                    itemBuilder: (context, dynamic tag) {
                      return ListTile(
                        title: Text(
                          tag,
                          style: TextStyle(color: appFontColor(), fontSize: 14.0, fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                    onSuggestionSelected: (dynamic val) {
                      tag.text = val;
                      model.setTagFilter(val);
                    },
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => model.clearTagFilter(),
                  child: Text(
                    "Clear Tag Filter",
                    style: TextStyle(
                      color: appTextButtonColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
