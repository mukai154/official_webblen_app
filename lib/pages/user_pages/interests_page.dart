import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:webblen/algolia/algolia_search.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';

class InterestsPage extends StatefulWidget {
  @override
  _InterestsPageState createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  bool isLoading = true;
  String uid;
  Map<dynamic, dynamic> allTags = {};
  String selectedCategory;
  List selectedTags = [];
  List<String> tagCategories = [];

  updateInterests() {
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenUserData().updateInterests(uid, selectedTags).then((err) {
      Navigator.of(context).pop();
      if (err == null) {
        showOkAlertDialog(
          context: context,
          message: "Interests Updated",
          okLabel: "Ok",
          barrierDismissible: true,
        );
      } else {
        showOkAlertDialog(
          context: context,
          message: "There was an issue updating your interests. Please try again.",
          okLabel: "Ok",
          barrierDismissible: true,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    BaseAuth().getCurrentUserID().then((res) {
      uid = res;
      WebblenUserData().getInterests(uid).then((res) {
        selectedTags = res;
        AlgoliaSearch().getTagsAndCategories().then((res) {
          allTags = res;
          allTags.keys.forEach((key) {
            if (key != null) {
              tagCategories.add(key.toString());
            }
          });
          tagCategories.sort((a, b) => a.compareTo(b));
          tagCategories.insert(0, "select category");
          selectedCategory = tagCategories.first;
          isLoading = false;
          setState(() {});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        "Interests",
        Padding(
          padding: EdgeInsets.only(right: 16, top: 18),
          child: GestureDetector(
            onTap: () => updateInterests(),
            child: Text(
              "Update",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? CustomLinearProgress(progressBarColor: CustomColors.webblenRed)
          : Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),
                  selectedCategory == null
                      ? Container()
                      : TextFieldContainer(
                          child: DropdownButton(
                              isExpanded: true,
                              underline: Container(),
                              value: selectedCategory,
                              items: tagCategories.map((String val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(val),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedCategory = val;
                                });
                              }),
                        ),
                  SizedBox(height: 24),
                  selectedCategory == null
                      ? Container()
                      : GridView.count(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          crossAxisCount: 3,
                          childAspectRatio: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: selectedCategory == 'select category'
                              ? List()
                              : List.generate(allTags[selectedCategory].length - 1, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (selectedTags.contains(allTags[selectedCategory][index])) {
                                        selectedTags.remove(allTags[selectedCategory][index]);
                                      } else {
                                        selectedTags.add(allTags[selectedCategory][index]);
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: selectedTags.contains(allTags[selectedCategory][index]) ? CustomColors.electronBlue : CustomColors.iosOffWhite,
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          allTags[selectedCategory][index],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: selectedTags.contains(allTags[selectedCategory][index]) ? Colors.white : Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                        ),
                ],
              ),
            ),
    );
  }
}
