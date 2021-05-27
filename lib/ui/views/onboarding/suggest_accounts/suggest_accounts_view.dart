import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/views/onboarding/suggest_accounts/suggest_accounts_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_linear_progress_indicator.dart';
import 'package:webblen/ui/widgets/user/user_profile_pic.dart';

class SuggestAccountsView extends StatelessWidget {
  Widget appBarLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: AppBarCircleProgressIndicator(color: appActiveColor(), size: 25),
    );
  }

  Widget doneButton(SuggestAccountsViewModel model) {
    return Padding(
      padding: EdgeInsets.only(right: 16, top: 18),
      child: CustomTextButton(
        onTap: () => model.completeOnboarding(),
        color: appFontColor(),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        text: 'Done',
        textAlign: TextAlign.right,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SuggestAccountsViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => SuggestAccountsViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicActionAppBar(
          title: 'Suggested Accounts',
          showBackButton: false,
          actionWidget: model.isBusy ? appBarLoadingIndicator() : doneButton(model),
        ),
        body: model.isBusy
            ? CustomLinearProgressIndicator(color: appActiveColor())
            : Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                color: appBackgroundColor(),
                child: RefreshIndicator(
                  color: appFontColor(),
                  backgroundColor: appBackgroundColor(),
                  onRefresh: model.initialize,
                  child: ListView.builder(
                    itemCount: model.suggestedUsers.length, //suggestedUsers.length,
                    itemBuilder: (context, index) {
                      return index == 0
                          ? Container(
                              child: Column(
                                children: [
                                  SizedBox(height: 16.0),
                                  Text(
                                    "Here Are a Few Others Nearby\nYou Should Checkout!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () => model.customNavigationService.navigateToUserView(model.suggestedUsers[index].id!),
                                          child: Row(
                                            children: [
                                              UserProfilePic(
                                                size: 60,
                                                userPicUrl: model.suggestedUsers[index].profilePicURL!,
                                                isBusy: false,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "@${model.suggestedUsers[index].username}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        model.newFollows.contains(model.suggestedUsers[index].id)
                                            ? CustomButton(
                                                text: "following",
                                                textColor: Colors.black,
                                                backgroundColor: CustomColors.iosOffWhite,
                                                elevation: 0.0,
                                                height: 30.0,
                                                width: 100,
                                                onPressed: () => model.unfollowUser(model.suggestedUsers[index].id!),
                                                isBusy: false,
                                              )
                                            : IconButton(
                                                icon: Icon(
                                                  FontAwesomeIcons.userPlus,
                                                  size: 18.0,
                                                  color: Colors.black,
                                                ),
                                                onPressed: () => model.followUser(model.suggestedUsers[index].id!),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => model.customNavigationService.navigateToUserView(model.suggestedUsers[index].id!),
                                    child: Row(
                                      children: [
                                        UserProfilePic(
                                          size: 60,
                                          userPicUrl: model.suggestedUsers[index].profilePicURL!,
                                          isBusy: false,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "@${model.suggestedUsers[index].username}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  model.newFollows.contains(model.suggestedUsers[index].id!)
                                      ? CustomButton(
                                          text: "following",
                                          textColor: Colors.black,
                                          backgroundColor: CustomColors.iosOffWhite,
                                          elevation: 0.0,
                                          height: 30.0,
                                          width: 100,
                                          onPressed: () => model.unfollowUser(model.suggestedUsers[index].id!),
                                          isBusy: false,
                                        )
                                      : IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.userPlus,
                                            size: 18.0,
                                            color: Colors.black,
                                          ),
                                          onPressed: () => model.followUser(model.suggestedUsers[index].id!),
                                        ),
                                ],
                              ),
                            );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
