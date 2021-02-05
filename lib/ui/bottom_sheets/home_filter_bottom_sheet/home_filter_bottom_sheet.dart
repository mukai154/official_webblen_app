import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

import 'home_filter_bottom_sheet_model.dart';

class HomeFilterBottomSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const HomeFilterBottomSheet({
    Key key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeFilterBottomSheetModel>.reactive(
      onModelReady: (model) => model.initialize(
        request.customData['currentSortBy'],
        request.customData['currentCityName'],
        request.customData['currentAreaCode'],
        request.customData['currentTagFilter'],
      ),
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
                Text(
                  "Preferences",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appFontColor(),
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
                      value: model.sortBy,
                      items: model.sortByList.map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (val) {}),
                ),
                SizedBox(height: 32),
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
                  height: 38,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                    ),
                    child: TypeAheadField(
                      hideOnEmpty: true,
                      hideOnLoading: true,
                      direction: AxisDirection.up,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: model.locationTextController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: model.cityName,
                          border: InputBorder.none,
                        ),
                        autofocus: false,
                      ),
                      suggestionsCallback: (searchTerm) async {
                        Map<String, dynamic> res = await model.googlePlacesService.googleSearchAutoComplete(key: model.googleAPIKey, input: searchTerm);
                        model.setPlacesSearchResults(res);
                        return model.placeSearchResults.keys.toList();
                      },
                      itemBuilder: (context, place) {
                        return ListTile(
                          title: Text(
                            place,
                            style: TextStyle(color: appFontColor(), fontSize: 14.0, fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                      onSuggestionSelected: (val) => model.getPlaceDetails(val),
                    ),
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
                SizedBox(height: 32),
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
                  height: 38,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                    ),
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
                        controller: model.tagTextController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: "Search for Tag",
                          border: InputBorder.none,
                        ),
                        autofocus: false,
                      ),
                      suggestionsCallback: (searchTerm) async {
                        return await model.algoliaSearchService.queryTags(searchTerm);
                      },
                      itemBuilder: (context, tag) {
                        return ListTile(
                          title: Text(
                            tag,
                            style: TextStyle(color: appFontColor(), fontSize: 14.0, fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                      onSuggestionSelected: (val) => model.setTagFilter(val),
                    ),
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
                FlatButton(
                  minWidth: screenWidth(context),
                  onPressed: () => completer(SheetResponse(responseData: model.returnPreferences())),
                  child: Text(
                    "Apply",
                    style: TextStyle(
                      color: appFontColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  color: appButtonColorAlt(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
