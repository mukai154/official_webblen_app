import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/ticket_distro.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class TicketSelectionPage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenEvent event;

  TicketSelectionPage({
    this.currentUser,
    this.event,
  });

  @override
  State<StatefulWidget> createState() {
    return _TicketSelectionPageState();
  }
}

class _TicketSelectionPageState extends State<TicketSelectionPage> {
  bool isLoading = true;
  //Keys
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ticketQuantityFormKey = GlobalKey<FormState>();
  final ticketPaymentFormKey = GlobalKey<FormState>();

  //Event Info
  WebblenUser eventHost;
  DateFormat formatter = DateFormat('MMM dd, yyyy h:mm a');
  TicketDistro ticketDistro;

  //payments
  List<String> ticketPurchaseAmounts = ['0', '1', '2', '3', '4'];
  List<Map<String, dynamic>> ticketsToPurchase = [];
  double chargeAmount = 0.00;
  List<String> ticketEmails = [];

  didSelectTicketQty(String selectedValue, int index) {
    chargeAmount = 0.00;
    int qtyAmount = int.parse(selectedValue);
    ticketsToPurchase[index]['qty'] = qtyAmount;
    ticketsToPurchase.forEach((ticket) {
      double ticketPrice = double.parse(ticket['ticketPrice'].toString().substring(1));
      double ticketCharge = ticketPrice * ticket['qty'];
      chargeAmount += ticketCharge;
    });
    setState(() {});
  }

  Widget ticketListBuilder() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: ticketsToPurchase.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 40.0,
            margin: EdgeInsets.only(top: 8.0),
            width: MediaQuery.of(context).size.width * 0.60,
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: 8.0,
                  ),
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: Fonts().textW400(
                    ticketsToPurchase[index]["ticketName"],
                    16.0,
                    Colors.black,
                    TextAlign.left,
                  ),
                ),
                Container(
                  width: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Fonts().textW400(
                        ticketsToPurchase[index]["ticketPrice"],
                        16.0,
                        Colors.black,
                        TextAlign.left,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: FlatColors.textFieldGray,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            4.0,
                          ),
                          child: DropdownButton<String>(
                            underline: Container(),
                            iconSize: 16.0,
                            isDense: true,
                            isExpanded: false,
                            value: ticketsToPurchase[index]['qty'].toString(),
                            items: ticketPurchaseAmounts.map((val) {
                              return DropdownMenuItem(
                                child: Fonts().textW400(val, 16.0, Colors.black, TextAlign.left),
                                value: val,
                              );
                            }).toList(),
                            onChanged: (val) => didSelectTicketQty(val, index),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserDataService().getUserByID(widget.event.authorID).then((res) {
      eventHost = res;
      EventDataService().getEventTicketDistro(widget.event.id).then((res) {
        ticketDistro = res;
        ticketDistro.tickets.forEach((ticket) {
          Map<String, dynamic> tData = Map<String, dynamic>.from(ticket);
          tData['qty'] = 0;
          ticketsToPurchase.add(tData);
        });
        isLoading = false;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar(
        "Ticket Details",
        context,
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? CustomLinearProgress(progressBarColor: FlatColors.webblenRed)
            : ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 16.0,
                        ),
                        Fonts().textW700(widget.event.title, 30.0, Colors.black, TextAlign.left),
                        SizedBox(
                          height: 4.0,
                        ),
                        Row(
                          children: <Widget>[
                            Fonts().textW400("Hosted By ", 16.0, Colors.black, TextAlign.left),
                            GestureDetector(
                              onTap: () =>
                                  PageTransitionService(context: context, currentUser: widget.currentUser, webblenUser: eventHost).transitionToUserPage(),
                              child: Fonts().textW400("@${eventHost.username}", 16.0, FlatColors.webblenRed, TextAlign.left),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Fonts().textW300(
                          formatter.format(
                            DateTime.fromMillisecondsSinceEpoch(widget.event.startDateTimeInMilliseconds),
                          ),
                          14.0,
                          Colors.black,
                          TextAlign.left,
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Container(
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: FlatColors.iosOffWhite,
                            border: Border.all(
                              color: Colors.black26,
                              width: 0.8,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(4.0),
                            ),
                          ),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                  left: 8.0,
                                ),
                                width: MediaQuery.of(context).size.width * 0.60,
                                child: Fonts().textW700(
                                  "Ticket Type",
                                  12.0,
                                  Colors.black,
                                  TextAlign.left,
                                ),
                              ),
                              Container(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Fonts().textW700(
                                          "Price",
                                          12.0,
                                          Colors.black,
                                          TextAlign.left,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Fonts().textW700(
                                          "Qty",
                                          12.0,
                                          Colors.black,
                                          TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ticketListBuilder(),
                      ],
                    ),
                  )
                ],
              ),
      ),
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: FlatColors.textFieldGray,
              width: 1.5,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomColorButton(
                text: "Proceed to Checkout",
                textSize: 14.0,
                textColor: chargeAmount == 0 ? Colors.black26 : Colors.white,
                backgroundColor: chargeAmount == 0 ? FlatColors.textFieldGray : FlatColors.darkMountainGreen,
                height: 40.0,
                width: MediaQuery.of(context).size.width * 0.9,
                onPressed: chargeAmount == 0
                    ? null
                    : () => PageTransitionService(
                            context: context,
                            currentUser: widget.currentUser,
                            event: widget.event,
                            ticketsToPurchase: ticketsToPurchase,
                            eventFees: ticketDistro.fees)
                        .transitionToTicketPurchasePage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
