import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';

class ShopItemDetailsPage extends StatefulWidget {
  final WebblenReward reward;
  ShopItemDetailsPage({this.reward});

  @override
  _ShopItemDetailsPageState createState() => _ShopItemDetailsPageState();
}

class _ShopItemDetailsPageState extends State<ShopItemDetailsPage> {
  int quantity = 1;

  List<bool> selectedColor = [true, false, false, false];

  Widget buildCard() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.fromLTRB(40, 20, 40, 20),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffdddddd),
        ),
//        width: MediaQuery.of(context).size.width -50,
//        height: MediaQuery.of(context).size.height / 3,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: CachedNetworkImage(
                  imageUrl: widget.reward.imageURL,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width - 80,
                ),
              ),
              flex: 6,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(widget.reward.cost.toStringAsFixed(2),
                              overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          margin: EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(color: Color(0xff36004f), borderRadius: BorderRadius.circular(15)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.star,
                                color: Colors.pink,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.pink,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.pink,
                              ),
                              Icon(
                                Icons.star_half,
                                color: Colors.pink,
                              ),
                              Icon(
                                Icons.star_border,
                                color: Colors.pink,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              flex: 1,
            )
          ],
        ),
      ),
    );
  }

  Widget buildChoice() {
    // TODO: change color to a drop down menu
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildColor(Colors.brown, 0),
              buildColor(Color(0xffba5d5d), 1),
              buildColor(Color(0xffb78484), 2),
              buildColor(Color(0xff912121), 3),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  }),
              Text(
                quantity.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      quantity = --quantity == 0 ? 1 : quantity;
                    });
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildColor(Color color, int i) {
    return InkWell(
      onTap: () {
        setState(() {
          for (int j = 0; j < selectedColor.length; j++) {
            selectedColor[j] = false;
            if (j == i) selectedColor[j] = true;
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(left: 8),
        child: selectedColor[i]
            ? Icon(
                Icons.check,
                size: 15,
                color: Colors.white,
              )
            : null,
        decoration: ShapeDecoration(color: color, shape: CircleBorder()),
        height: 20,
        width: 20,
      ),
    );
  }

  Widget buildAddToRow() {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: FlatButton(
                  onPressed: null,
                  child: Text(
                    "ADD TO CART",
                    style: TextStyle(color: Colors.white),
                  )),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [Colors.pink, Colors.pinkAccent, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            flex: 3,
          ),
          Expanded(
              child: Container(
//            margin: EdgeInsets.only(left: 30, right: 20),
            decoration: ShapeDecoration(shape: CircleBorder(), color: Color(0xffdddddd)),
            child: Icon(
              Icons.favorite_border,
              color: Colors.black,
            ),
            padding: EdgeInsets.all(10),
          ))
        ],
      ),
    );
  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        elevation: 0.0,
//        title: Text("Back to Shopping"),
//      ),
//      body: ListView(
//        children: <Widget>[
//          buildProduct(),
//          buildChoicesRow(),
//          buildBuyRow(),
//          Divider(),
//          buildDescription(),
//          Divider(),
//        ],
//      ),
//    );
//  }

  // TODO: Change text UI
  Widget buildProduct() {
    return Container(
      height: 200.0,
      child: GridTile(
        child: Container(
          color: Colors.white,
          child: CachedNetworkImage(
            imageUrl: widget.reward.imageURL,
            fit: BoxFit.fitHeight,
            width: MediaQuery.of(context).size.width - 80,
          ),
        ),
        footer: Container(
          color: Colors.white,
          child: ListTile(
            leading: Text(widget.reward.title, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Text(widget.reward.cost.toStringAsFixed(2),
                      overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChoicesRow() {
    return Container(
      color: Color(0xffe5e3e3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: buildChoiceButton("Size"),
              margin: EdgeInsets.all(5),
            ),
            flex: 3,
          ),
          Expanded(
              child: Container(
                child: buildChoiceButton("Color"),
                margin: EdgeInsets.all(5),
              ),
              flex: 3),
          Expanded(
            child: Container(
              child: buildChoiceButton("Quantity"),
              margin: EdgeInsets.all(5),
            ),
            flex: 4,
          ),
        ],
      ),
    );
  }

  Widget buildChoiceButton(String text) {
    return MaterialButton(
      color: Colors.white,
      textColor: Colors.grey,
      elevation: 0.2,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            flex: 2,
          ),
          Expanded(child: Icon(Icons.arrow_drop_down))
        ],
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(text),
                content: Text("Choose the $text"),
                actions: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop(context);
                    },
                    child: Text("close"),
                  )
                ],
              );
            });
      },
    );
  }

  Widget buildBuyRow() {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          Expanded(child: MaterialButton(onPressed: () {}, color: Colors.pink, textColor: Colors.white, elevation: 0.2, child: Text("Buy now"))),
          IconButton(icon: Icon(Icons.add_shopping_cart), color: Colors.pink, onPressed: () {}),
          IconButton(icon: Icon(Icons.favorite_border), color: Colors.pink, onPressed: () {})
        ],
      ),
    );
  }

  Widget buildDescription() {
    return ListTile(
      title: Text("Details"),
      subtitle: Text("A very valuable item that will surly stun anyone who look at it, Give it a try. The sure thing is that you won't regret it."),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar("Details", context),
      body: Container(
        child: ListView(
          children: [
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: CachedNetworkImage(
                imageUrl: widget.reward.imageURL,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    widget.reward.title,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/webblen_coin.png',
                            height: 20.0,
                            width: 20.0,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            widget.reward.cost.toStringAsFixed(2),
                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: CustomColors.textFieldGray,
              width: 1.5,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Total",
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/webblen_coin.png',
                        height: 20.0,
                        width: 20.0,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        widget.reward.cost.toStringAsFixed(2),
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomColorButton(
                    text: "Purchase",
                    textSize: 14.0,
                    textColor: Colors.white,
                    backgroundColor: CustomColors.darkMountainGreen,
                    height: 35.0,
                    width: MediaQuery.of(context).size.width * 0.4,
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
