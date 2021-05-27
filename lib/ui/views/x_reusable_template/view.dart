import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/ui/views/x_reusable_template/view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';

class XView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<XViewModel>.reactive(
      viewModelBuilder: () => XViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(title: 'Title', showBackButton: true),
      ),
    );
  }
}
