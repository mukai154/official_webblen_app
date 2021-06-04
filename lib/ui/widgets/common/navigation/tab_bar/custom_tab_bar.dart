import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';

class WebblenHomePageTabBar extends StatelessWidget {
  final TabController? tabController;
  WebblenHomePageTabBar({this.tabController});

  final FontWeight fontWeight = FontWeight.w600;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: EdgeInsets.only(bottom: 4),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelPadding: EdgeInsets.symmetric(horizontal: 10),
        indicatorColor: appActiveColor(),
        labelColor: Colors.white,
        unselectedLabelColor: appInActiveColorAlt(),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(borderRadius: BorderRadius.circular(10), color: appActiveColor()),
        tabs: [
          Tab(
            child: Container(
              height: 30,
              width: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Posts",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              height: 30,
              width: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Streams",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              height: 30,
              width: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Events",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebblenAllSearchResultsTabBar extends StatelessWidget {
  final TabController? tabController;
  WebblenAllSearchResultsTabBar({this.tabController});

  @override
  Widget build(BuildContext context) {
    FontWeight fontWeight = FontWeight.w600;
    return Container(
      height: 30,
      padding: EdgeInsets.only(bottom: 4),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelPadding: EdgeInsets.symmetric(horizontal: 10),
        indicatorColor: appActiveColor(),
        labelColor: Colors.white,
        unselectedLabelColor: appInActiveColorAlt(),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appActiveColor(),
        ),
        tabs: [
          Tab(
            child: Container(
              height: 30,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Posts",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              height: 30,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Streams",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              height: 30,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Events",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              height: 30,
              width: 115,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "People/Groups",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebblenProfileTabBar extends StatelessWidget {
  final TabController? tabController;
  WebblenProfileTabBar({this.tabController});

  @override
  Widget build(BuildContext context) {
    FontWeight fontWeight = FontWeight.w600;
    return Container(
      height: 35,
      padding: EdgeInsets.only(top: 4, bottom: 8),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelPadding: EdgeInsets.symmetric(horizontal: 10),
        indicatorColor: appActiveColor(),
        labelColor: Colors.white,
        unselectedLabelColor: appInActiveColorAlt(),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(borderRadius: BorderRadius.circular(10), color: appActiveColor()),
        tabs: [
          Tab(
            child: Container(
              height: 30,
              width: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Posts",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              height: 30,
              width: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Streams",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              height: 30,
              width: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Events",
                  style: TextStyle(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
          // Tab(
          //   child: Container(
          //     height: 30,
          //     width: 75,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(60),
          //     ),
          //     child: Align(
          //       alignment: Alignment.center,
          //       child: Text(
          //         "Activity",
          //         style: TextStyle(fontWeight: fontWeight),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
