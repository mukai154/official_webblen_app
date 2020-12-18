import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';

import 'messages_view_model.dart';

class MessagesView extends StatelessWidget {
  Widget head(MessagesViewModel model) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Messages",
            style: TextStyle(
              color: appFontColor(),
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: null, //() => model.navigateToCreateCauseView(),
                  icon: Icon(FontAwesomeIcons.plus, color: appIconColor(), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget listMessages(MessagesViewModel model) {
    return Expanded(
      child: ListView.builder(
        controller: null,
        physics: AlwaysScrollableScrollPhysics(),
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: 0, //model.causes.length,
        itemBuilder: (context, index) {
          return Container();
          // CauseBlockView(
          //   currentUID: model.currentUID,
          //   cause: model.causes[index],
          //   showOptions: null,
          // );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MessagesViewModel>.reactive(
      //onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => MessagesViewModel(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                head(model),
                listMessages(model),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
