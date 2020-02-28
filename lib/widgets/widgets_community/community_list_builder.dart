import 'package:flutter/material.dart';

import 'package:webblen/models/community.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/widgets_community/community_row.dart';

class CommunityListBuilder extends StatelessWidget {
  final WebblenUser currentUser;
  final List<Community> communities;

  CommunityListBuilder({
    this.currentUser,
    this.communities,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      itemCount: communities.length,
      itemBuilder: (context, index) {
        return CommunityRow(
          showAreaName: true,
          community: communities[index],
          onClickAction: () => PageTransitionService(
            context: context,
            currentUser: currentUser,
            community: communities[index],
          ).transitionToCommunityProfilePage(),
        );
      },
    );
  }
}
