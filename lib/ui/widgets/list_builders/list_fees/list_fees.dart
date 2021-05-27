import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class ListFeesForEditing extends StatelessWidget {
  final WebblenTicketDistro ticketDistro;
  final Function(int) editFeeAtIndex;

  ListFeesForEditing({required this.ticketDistro, required this.editFeeAtIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 20,
            child: CustomText(
              text: 'FEES',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: appFontColorAlt(),
            ),
          ),
          verticalSpaceTiny,
          Container(
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: appDividerColor(),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.only(right: 4),
                    child: CustomText(
                      text: 'Fee Name',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: appFontColor(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 1,
                    margin: EdgeInsets.only(right: 4),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 4),
                    child: CustomText(
                      text: 'Price',
                      textAlign: TextAlign.right,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: appFontColor(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
          verticalSpaceSmall,
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ticketDistro.fees!.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.only(right: 4),
                        child: CustomText(
                          text: ticketDistro.fees![index]["feeName"],
                          color: appFontColor(),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(right: 4),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(right: 4),
                        child: CustomText(
                          text: ticketDistro.fees![index]["feePrice"],
                          color: appFontColor(),
                          textAlign: TextAlign.right,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => editFeeAtIndex(index),
                              child: Icon(FontAwesomeIcons.edit, size: 14.0, color: appFontColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
