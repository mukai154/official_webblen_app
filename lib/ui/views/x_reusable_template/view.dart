import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/ui/views/x_reusable_template/view_model.dart';

class XView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<XViewModel>.reactive(
      viewModelBuilder: () => XViewModel(),
      builder: (context, model, child) => Scaffold(),
    );
  }
}
