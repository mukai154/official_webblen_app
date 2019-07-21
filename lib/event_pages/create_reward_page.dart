import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/firebase_data/reward_data.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webblen/utils/strings.dart';

final homeScaffoldKey = new GlobalKey<ScaffoldState>();
final searchScaffoldKey = new GlobalKey<ScaffoldState>();


class CreateRewardPage extends StatefulWidget {

  @override
  _CreateRewardPageState createState() => _CreateRewardPageState();
}

class _CreateRewardPageState extends State<CreateRewardPage> {

  //Firebase
  String uid;
  String rewardKey;
  String rewardProviderName;
  String rewardDescription;
  String rewardImagePath;
  File rewardImage;
  String rewardExpirationDate;
  String rewardAddress;
  double rewardLat;
  double rewardLon;
  String rewardCostText;
  double rewardCost;
  String rewardCategory;
  String amountAvailableText;
  String rewardPromoCode = "";
  String rewardBarcodeNumber = "";
  String rewardUrl = "";
  String rewardType;
  int amountAvailable;
  String username = "";
  bool isLoading = false;
  bool uploadedImage = false;
  final StorageReference storageReference = FirebaseStorage.instance.ref();
  final rewardFormKey = new GlobalKey<FormState>();
  final String googleAPIKey = Strings.googleAPIKEY;


  //Form Validations
  void validateReward(){
    setState(() {
      isLoading = true;
    });
    ScaffoldState scaffold = homeScaffoldKey.currentState;
    final form = rewardFormKey.currentState;
    form.save();
    if (rewardProviderName.isEmpty) {
      scaffold.showSnackBar(new SnackBar(
        content: new Text("Reward Name Cannot be Empty"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
      setState(() {
        isLoading = false;
      });
    } else if (rewardDescription.isEmpty){
      scaffold.showSnackBar(new SnackBar(
        content: new Text("Description Cannot be Empty"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
      setState(() {
        isLoading = false;
      });
    } else if (rewardCostText == null){
      scaffold.showSnackBar(new SnackBar(
        content: new Text("Reward Must be Worth At Least 10 pts"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
      setState(() {
        isLoading = false;
      });
    } else if (rewardImage == null){
      scaffold.showSnackBar(new SnackBar(
        content: new Text("Reward Must Have Image"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
      setState(() {
        isLoading = false;
      });
    } else if (rewardExpirationDate == null){
      scaffold.showSnackBar(new SnackBar(
        content: new Text("Reward Must Have Date"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
      setState(() {
        isLoading = false;
      });
    } else if (rewardLat == null || rewardLon == null){
      scaffold.showSnackBar(new SnackBar(
        content: new Text("Reward Must Have a Location"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
      setState(() {
        isLoading = false;
      });
    } else {
      rewardCost = double.parse(rewardCostText);
      amountAvailable = int.parse(amountAvailableText);
      WebblenReward newReward = createReward();
      uploadReward(rewardImage, newReward);
    }
  }

  void handleNewDate(DateTime selectedDate) {
    ScaffoldState scaffold = homeScaffoldKey.currentState;
    DateTime today = DateTime.now();
    if (selectedDate.isBefore(today)) {
      scaffold.showSnackBar(new SnackBar(
        content: new Text("Invalid Event Date"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
    } else {
      DateFormat formatter = new DateFormat('MM/dd/yyyy');
      rewardExpirationDate = formatter.format(selectedDate);
    }
  }

  void imagePicker() async {
    //File img = await ImagePicker.pickImage(source: ImageSource.camera);
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      cropImage(img);
      setState(() {});
    }
  }

  void cropImage(File img) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: img.path,
        ratioX: 1.0,
        ratioY: 1.0,
        toolbarTitle: 'Cropper',
        toolbarColor: FlatColors.exodusPurple
    );
    if (croppedFile != null) {
      rewardImage = croppedFile;
      setState(() {});
    }
  }

  Future<bool> invalidAlert(BuildContext context) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              child: Column(
                children: <Widget>[
                  Image.asset("assets/images/warning.png", height: 45.0, width: 45.0),
                  SizedBox(height: 8.0),
                  Fonts().textW700("Cancel Reward Creation?", 32.0, FlatColors.darkGray, TextAlign.center),
                ],
              ),
            ),
            content: Fonts().textW500("Any progress you've made will be lost.", 18.0, FlatColors.darkGray, TextAlign.center),
            actions: <Widget>[
              new FlatButton(
                child: Fonts().textW700("Cancel Reward Creation?", 32.0, FlatColors.darkGray, TextAlign.center),
                //new Text("No", style: Fonts.alertDialogAction),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: Fonts().textW700("Cancel Reward Creation?", 32.0, FlatColors.darkGray, TextAlign.center),
                //new Text("Yes", style: Fonts.alertDialogAction),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<bool> successAlert(BuildContext context) {
    setState(() {
      isLoading = false;
    });
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title:Container(
              child: Column(
                children: <Widget>[
                  Image.asset("assets/images/checked.png", height: 45.0, width: 45.0),
                  SizedBox(height: 8.0),
                  Fonts().textW700("Cancel Reward Creation?", 32.0, FlatColors.darkGray, TextAlign.center),
                  //Text("Reward Submitted!", style: Fonts.alertDialogHeader, textAlign: TextAlign.center),
                ],
              ),
            ),
            content: Fonts().textW700("Cancel Reward Creation?", 32.0, FlatColors.darkGray, TextAlign.center),
            //new Text("Your Rewards Will Be Reviewed to be Placed in the Store", style: Fonts.alertDialogBody, textAlign: TextAlign.center),
            actions: <Widget>[
              new FlatButton(
                child: Fonts().textW700("Cancel Reward Creation?", 32.0, FlatColors.darkGray, TextAlign.center),
                //new Text("Ok", style: Fonts.alertDialogAction),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<bool> failedAlert(BuildContext context, String details) {
    setState(() {
      isLoading = false;
    });
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              child: Column(
                children: <Widget>[
                  Image.asset("assets/images/warning.png", height: 45.0, width: 45.0),
                  SizedBox(height: 8.0),
                  Fonts().textW700("Place Text Here", 32.0, FlatColors.darkGray, TextAlign.center),
                  //Text("Reward Submission Failed", style: Fonts.alertDialogHeader, textAlign: TextAlign.center),
                ],
              ),
            ),
            content: Fonts().textW700("Place Text Here", 32.0, FlatColors.darkGray, TextAlign.center),
            //new Text("There Was an Issue Submitting Your Reward: $details", style: Fonts.alertDialogBody, textAlign: TextAlign.center),
            actions: <Widget>[
              new FlatButton(
                child: Fonts().textW700("Place Text Here", 32.0, FlatColors.darkGray, TextAlign.center),
                //new Text("Ok", style: Fonts.alertDialogAction),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  uploadReward(File image, WebblenReward reward) async {
    setState(() {
      isLoading = true;
    });
    RewardDataService().uploadReward(image, reward).then((result){
      if (result.toString() == "success"){
        successAlert(context);
      } else {
        failedAlert(context, result.toString());
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: homeScaffoldKey,
        body: Container(
          color: FlatColors.darkMountainGreen,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: new ListView(
              children: <Widget>[
                new Form(
                  key: rewardFormKey,
                  child: new Column(
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      _buildCancelButton(Colors.white70),
                      SizedBox(height: 30.0),
                      addImageButton(),
                      SizedBox(height: 8.0),
                      _buildRewardProviderField(),
                      SizedBox(height: 8.0),
                      _buildRewardDescriptionField(),
                      SizedBox(height: 8.0),
                      _buildRewardPromoField(),
                      SizedBox(height: 8.0),
                      _buildRewardUrlField(),
                      SizedBox(height: 8.0),
                      _buildRewardCostField(),
                      SizedBox(height: 8.0),
                      _buildAmountAvailableField(),
                      SizedBox(height: 8.0),
                      _buildCalendar(),
                      SizedBox(height: 8.0),
                      _buildSearchAutoComplete(),
                      SizedBox(height: 8.0),
                      isLoading 
                      ? _buildLoadingIndicator() 
                      : CustomColorButton(
                        text: "Submit Reward",
                        textColor: Colors.white,
                        backgroundColor: FlatColors.blueGray,
                        height: 45.0,
                        width: 200.0,
                        onPressed: () => validateReward(),
                      ),
                      SizedBox(height: 24.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget addImageButton() {
    return Material(
      borderRadius: BorderRadius.circular(40.0),
      elevation: 0.0,
      child: MaterialButton(
        height: 60.0,
        elevation: 0.0,
        color: FlatColors.darkMountainGreen,
        onPressed: imagePicker,
        child: rewardImage == null
            ? Container(
            height: 80.0,
            width: 80.0,
            child: Icon(Icons.camera_alt, size: 40.0, color: Colors.white))
            : ClipRRect(
          borderRadius: BorderRadius.circular(40.0),
          child: Image.file(rewardImage, width: 80.0, height: 80.0),
        ),
      ),
    );
  }

  Widget _buildCancelButton(Color color){
    return new Row(
      children: <Widget>[
        SizedBox(width: 4.0),
        IconButton(
          icon: Icon(FontAwesomeIcons.times, color: Colors.white, size: 24.0),
          onPressed: () => invalidAlert(context),
        ),
      ],
    );
  }

  Widget _buildRewardProviderField(){
    return new Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: new TextFormField(
        initialValue: rewardProviderName,
        maxLength: 30,
        style: new TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.w700),
        autofocus: false,
        onSaved: (value) => rewardProviderName = value,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Reward Provider",
          counterStyle: TextStyle(fontFamily: 'Barlow'),
          contentPadding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
        ),
      ),
    );
  }

  Widget _buildRewardDescriptionField(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: new BorderRadius.circular(16.0),
      ),
      child: new TextFormField(
        initialValue: rewardDescription,
        maxLines: 2,
        autofocus: false,
        onSaved: (value) => rewardDescription = value,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Reward Description",
          counterStyle: TextStyle(fontFamily: 'Barlow'),
          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        ),
      ),
    );
  }

  Widget _buildRewardPromoField(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: new BorderRadius.circular(16.0),
      ),
      child: new TextFormField(
        initialValue: rewardPromoCode,
        maxLines: 1,
        autofocus: false,
        onSaved: (value) => rewardPromoCode = value,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Reward Code",
          counterStyle: TextStyle(fontFamily: 'Barlow'),
          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        ),
      ),
    );
  }

  Widget _buildRewardUrlField(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: new BorderRadius.circular(16.0),
      ),
      child: new TextFormField(
        initialValue: rewardUrl,
        maxLines: 1,
        autofocus: false,
        onSaved: (value) => rewardUrl = value,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Reward Url",
          counterStyle: TextStyle(fontFamily: 'Barlow'),
          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        ),
      ),
    );
  }

  Widget _buildRewardCostField(){
    return new Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: new TextFormField(
        keyboardType: TextInputType.number,
        style: new TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.w700),
        autofocus: false,
        onSaved: (value) => rewardCostText = value,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Reward Cost",
          counterStyle: TextStyle(fontFamily: 'Barlow'),
          contentPadding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
        ),
      ),
    );
  }

  Widget _buildAmountAvailableField(){
    return new Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: new TextFormField(
        keyboardType: TextInputType.number,
        style: new TextStyle(color: Colors.white, fontSize: 30.0, fontWeight: FontWeight.w700),
        autofocus: false,
        onSaved: (value) => amountAvailableText = value,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Amount Available",
          counterStyle: TextStyle(fontFamily: 'Barlow'),
          contentPadding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
        ),
      ),
    );
  }

  Widget _buildSearchAutoComplete(){
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 16.0),
        new RaisedButton(
            color: Colors.white70,
            onPressed: () async {
              // show input autocomplete with selected mode
              // then get the Prediction selected

              Prediction p = await PlacesAutocomplete.show(
                  context: context,
                  apiKey: googleAPIKey,
                  mode: Mode.overlay,
                  onError: (res) {
                    homeScaffoldKey.currentState.showSnackBar(
                        new SnackBar(content: new Text(res.errorMessage)));
                  },
                  language: "fr",
                  components: [new Component(Component.country, "fr")]);
              PlacesDetailsResponse detail = await GoogleMapsPlaces().getDetailsByPlaceId(p.placeId);
              setState(() {
                rewardLat = detail.result.geometry.location.lat;
                rewardLon = detail.result.geometry.location.lng;
                rewardAddress = p.description;
              });
            },
            child: new Text(rewardAddress == null ? "Set Location" : "$rewardAddress")),
      ],
    );
  }

  Widget _buildCalendar(){
    return new Container(
      margin: new EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: new Column(
        children: <Widget>[
          //Calendar
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(){
    return Theme(
      data: ThemeData(
          accentColor: Colors.white
      ),
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(backgroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  WebblenReward createReward(){
    WebblenReward reward = WebblenReward(
      rewardCost: rewardCost,
      rewardDescription: rewardDescription,
      rewardImagePath: "",
      rewardKey: "",
      rewardLat: rewardLat,
      rewardLon: rewardLon,
      rewardProviderName: rewardProviderName,
      rewardBarcodeNumber: rewardBarcodeNumber,
      rewardCategory: rewardCategory,
      rewardPromoCode: rewardPromoCode,
      rewardType: rewardType,
      rewardUrl: rewardUrl,
      amountAvailable: amountAvailable,
      expirationDate: rewardExpirationDate
    );
    return reward;
  }

}