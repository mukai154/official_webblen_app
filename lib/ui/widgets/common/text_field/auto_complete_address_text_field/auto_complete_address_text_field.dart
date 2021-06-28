import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/text_field/auto_complete_address_text_field/auto_complete_address_text_field_model.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class AutoCompleteAddressTextField extends StatelessWidget {
  final String initialValue;
  final String hintText;
  final bool showCurrentLocationButton;
  final Function(Map<String, dynamic>) onSelectedAddress;

  AutoCompleteAddressTextField({required this.initialValue, required this.hintText, required this.showCurrentLocationButton, required this.onSelectedAddress});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AutoCompleteAddressTextFieldModel>.reactive(
      onModelReady: (model) => model.initialize(initialValue: initialValue),
      viewModelBuilder: () => AutoCompleteAddressTextFieldModel(),
      builder: (context, model, child) => Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFieldContainer(
              height: 38,
              child: TypeAheadField(
                hideOnEmpty: true,
                hideOnLoading: true,
                getImmediateSuggestions: false,
                animationDuration: Duration(milliseconds: 0),
                direction: AxisDirection.up,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: model.locationTextController,
                  cursorColor: appFontColor(),
                  style: TextStyle(
                    color: appFontColor(),
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 10),
                    hintText: hintText,
                    border: InputBorder.none,
                  ),
                  autofocus: false,
                ),
                suggestionsCallback: (searchTerm) async {
                  Map<String, dynamic> res = await model.googlePlacesService.googleSearchAutoComplete(key: model.googleAPIKey, input: searchTerm);
                  model.setPlacesSearchResults(res);
                  return res.keys.toList();
                },
                itemBuilder: (context, dynamic place) {
                  return ListTile(
                    title: Text(
                      place,
                      style: TextStyle(color: appFontColor(), fontSize: 14.0, fontWeight: FontWeight.w500),
                    ),
                  );
                },
                onSuggestionSelected: (dynamic val) async {
                  Map<String, dynamic> details = await model.getPlaceDetails(val);
                  onSelectedAddress(details);
                },
              ),
            ),
            showCurrentLocationButton ? verticalSpaceTiny : Container(),
            showCurrentLocationButton
                ? CustomTextButton(
                    onTap: () async {
                      Map<String, dynamic> details = await model.getCurrentLocation();
                      onSelectedAddress(details);
                    },
                    text: "Use Current Location",
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appTextButtonColor(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
