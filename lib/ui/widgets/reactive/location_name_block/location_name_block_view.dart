import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';

import 'location_name_block_view_model.dart';

class LocationBlockView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LocationBlockViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      fireOnModelReadyOnce: true,
      viewModelBuilder: () => LocationBlockViewModel(),
      builder: (context, model, child) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          model.isBusy ? "" : "${model.cityName}",
          style: TextStyle(
            color: appFontColor(),
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
      ),
    );
  }
}
