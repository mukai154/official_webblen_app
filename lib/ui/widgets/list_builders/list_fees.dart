import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class ListFeesForEditing extends StatelessWidget {
  final WebblenTicketDistro? ticketDistro;
  final Function(int) editFeeAtIndex;

  ListFeesForEditing({required this.ticketDistro, required this.editFeeAtIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: appDividerColor(),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Container(
              width: (MediaQuery.of(context).size.width - 16) * 0.40,
              child: CustomText(
                text: 'FEES',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: appFontColorAlt(),
              ),
            ),
          ),
          verticalSpaceTiny,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: appDividerColor(),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: (MediaQuery.of(context).size.width - 16) * 0.40,
                  child: CustomText(
                    text: 'Fee Name',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appFontColor(),
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width - 16) * 0.20,
                  child: CustomText(
                    text: 'Price',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appFontColor(),
                  ),
                ),
                Container(width: 35.0),
              ],
            ),
          ),
          verticalSpaceSmall,
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ticketDistro!.fees!.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 150,
                      child: CustomText(
                        text: ticketDistro!.fees![index]["feeName"],
                        color: appFontColor(),
                        textAlign: TextAlign.left,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 70.0,
                      child: CustomText(
                        text: ticketDistro!.fees![index]["feePrice"],
                        color: appFontColor(),
                        textAlign: TextAlign.left,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 35.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => editFeeAtIndex(index),
                            child: Icon(FontAwesomeIcons.edit, size: 16.0, color: appFontColor()),
                          ),
                        ],
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
