import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

import 'explorer_path_view_model.dart';

class ExplorerPathView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ExplorerPathViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => ExplorerPathViewModel(),
      builder: (context, model, child) => Scaffold(
        body: IntroductionScreen(
          globalBackgroundColor: Colors.white,
          key: model.introKey,
          freeze: true,
          onChange: (val) {
            model.updatePageNum(val);
            if (model.pageNum == 0 || model.pageNum == 3 || model.pageNum == 2) {
              model.updateShowNextButton(true);
            } else {
              model.updateShowNextButton(false);
            }
          },
          onDone: () => model.completeOnboarding(),
          onSkip: () {
            if (model.pageNum == 0) {
              model.navigateToSelectPath();
            } else {
              model.navigateToPreviousPage();
            }
          },
          showSkipButton: model.showSkipButton,
          showNextButton: model.showNextButton,
          skipFlex: 0,
          nextFlex: 0,
          skip: Text('Back', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          next: Icon(FontAwesomeIcons.arrowRight, size: 24.0, color: Colors.black),
          done: Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          dotsDecorator: DotsDecorator(
            size: Size(10.0, 10.0),
            color: CustomColors.iosOffWhite,
            activeColor: CustomColors.webblenRed,
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
          pages: [
            ExplorePathPages().initialPage(),
            ExplorePathPages().selectInterestsPage(model),
          ],
        ),
      ),
    );
  }
}

class _OnboardingImage extends StatelessWidget {
  final String assetName;
  _OnboardingImage({required this.assetName});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Image.asset(
          'assets/images/$assetName.png',
          height: 200,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class ExplorePathPages {
  PageDecoration pageDecoration = PageDecoration(
    contentMargin: EdgeInsets.all(0),
    titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
    bodyTextStyle: TextStyle(fontSize: 16.0),
    titlePadding: EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16, right: 16),
    imageFlex: 1,
    descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
    pageColor: Colors.white,
    //imagePadding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
  );

  PageViewModel initialPage() {
    return PageViewModel(
      title: "Always Have Something to Do",
      body: "Webblen Helps You Find Posts, Events, Streams, and People in Your Area that Share Your Interests",
      image: _OnboardingImage(assetName: 'party'),
      decoration: pageDecoration,
    );
  }

  PageViewModel selectInterestsPage(ExplorerPathViewModel model) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 80),
            Text(
              "What Are You Interested In?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFieldContainer(
              child: DropdownButton(
                isExpanded: true,
                underline: Container(),
                value: model.selectedCategory,
                items: model.tagCategories.map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) => model.updateSelectedCategory(val!.toString()),
              ),
            ),
            SizedBox(height: 24),
            Divider(
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
              color: Colors.black45,
            ),
            model.selectedCategory == 'select category'
                ? Container()
                : GridView.count(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: List.generate(model.allTags[model.selectedCategory].length - 1, (index) {
                      return GestureDetector(
                        onTap: () => model.updateSelectedTags(model.allTags[model.selectedCategory][index]),
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: model.selectedTags.contains(model.allTags[model.selectedCategory][index])
                                ? CustomColors.webblenMatteBlue
                                : CustomColors.iosOffWhite,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              model.allTags[model.selectedCategory][index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: model.selectedTags.contains(model.allTags[model.selectedCategory][index]) ? Colors.white : Colors.black,
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
      bodyWidget: Container(),
      decoration: pageDecoration,
    );
  }
}

// class _OnboardingImage extends HookViewModelWidget<ExplorerPathViewModel> {
//   @override
//   Widget buildViewModelWidget(BuildContext context, SetUpDirectDepositViewModel model) {
//     var accountHolderName = useTextEditingController();
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.0),
//         child: Image.asset(
//           'assets/images/$assetName.png',
//           height: 200,
//           fit: BoxFit.contain,
//           filterQuality: FilterQuality.medium,
//         ),
//       ),
//     );
//   }
// }
