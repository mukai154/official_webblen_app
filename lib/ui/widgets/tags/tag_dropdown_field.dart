import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class TagDropdownField extends StatelessWidget {
  final bool enabled;
  final TextEditingController controller;
  final Function(String) onTagSelected;
  TagDropdownField({@required this.enabled, @required this.controller, @required this.onTagSelected});

  final AlgoliaSearchService _algoliaSearchService = locator<AlgoliaSearchService>();

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      height: 50,
      width: 300,
      child: TypeAheadField(
        hideOnEmpty: false,
        hideOnLoading: false,
        direction: AxisDirection.up,
        textFieldConfiguration: TextFieldConfiguration(
          enabled: enabled,
          controller: controller,
          cursorColor: appCursorColor(),
          decoration: InputDecoration(
            hintText: "Search for Tags",
            border: InputBorder.none,
          ),
          autofocus: false,
        ),
        loadingBuilder: (context) {
          return ListTile(
            title: CustomText(
              text: 'searching...',
              fontSize: 14,
              textAlign: TextAlign.left,
              fontWeight: FontWeight.w500,
              color: appFontColorAlt(),
            ),
          );
        },
        noItemsFoundBuilder: (context) {
          return controller.text.trim().isEmpty
              ? Container(
                  height: 0,
                  width: 0,
                )
              : ListTile(
                  title: CustomText(
                    text: "No results found for '${controller.text}'",
                    fontSize: 14,
                    textAlign: TextAlign.left,
                    fontWeight: FontWeight.w500,
                    color: appFontColorAlt(),
                  ),
                );
        },
        suggestionsCallback: (searchTerm) async {
          return await _algoliaSearchService.queryTags(searchTerm);
        },
        itemBuilder: (context, tag) {
          return ListTile(
            title: CustomText(
              text: tag,
              fontSize: 14,
              textAlign: TextAlign.left,
              fontWeight: FontWeight.bold,
              color: appFontColor(),
            ),
          );
        },
        onSuggestionSelected: (tag) => onTagSelected(tag),
      ),
    );
  }
}
