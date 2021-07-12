import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/ui/views/base/app_base_view_model.dart';
import 'package:webblen/ui/views/search/search_view.dart';
import 'package:webblen/ui/widgets/mini_video_player/mini_video_player_view_model.dart';

class CustomNavigationService {
  NavigationService _navigationService = locator<NavigationService>();
  MiniVideoPlayerViewModel _miniVideoPlayerViewModel = locator<MiniVideoPlayerViewModel>();

  navigateBack() {
    _navigationService.back();
  }

  navigateToBase() {
    _navigationService.pushNamedAndRemoveUntil(Routes.AppBaseViewRoute(page: null));
  }

  ///AUTH
  navigateToAuthView() {
    _navigationService.pushNamedAndRemoveUntil(Routes.AuthViewRoute);
  }

  ///ONBOARDING
  navigateToOnboardingView() {
    _navigationService.pushNamedAndRemoveUntil(Routes.OnboardingPathSelectViewRoute);
  }

  navigateToCompleteOnboardingView() {
    _navigationService.pushNamedAndRemoveUntil(Routes.OnboardingCompleteViewRoute);
  }

  ///POSTS
  navigateToPostView(String id) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.PostViewRoute(id: id));
  }

  navigateToCreatePostView(String id) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.CreatePostViewRoute(id: id, promo: "0"));
  }

  navigateToCreatePostViewWithPromo(String id, String promo) {
    _navigationService.navigateTo(Routes.CreatePostViewRoute(id: id, promo: promo));
  }

  ///EVENTS
  navigateToEventView(String id) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.EventViewRoute(id: id));
  }

  navigateToCreateEventView(String id) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.CreateEventViewRoute(id: id, promo: "0"));
  }

  navigateToCreateFlashEventView(String id) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.CreateFlashEventViewRoute(id: id, promo: "0"));
  }

  navigateToCreateEventViewWithPromo(String id, String promo) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.CreateEventViewRoute(id: id, promo: promo));
  }

  navigateToCheckInEventAttendees(String id) {
    _navigationService.navigateTo(Routes.CheckInAttendeesViewRoute(id: id));
  }

  navigateToTicketScanner(String id) {
    _navigationService.navigateTo(Routes.ScanAttendeesViewRoute(id: id));
  }

  ///TICKETS
  navigateToMyTicketsView() {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.MyTicketsViewRoute);
  }

  navigateToEventTickets(String id) {
    _navigationService.navigateTo(Routes.EventTicketsViewRoute(id: id));
  }

  navigateToTicketView(String id) {
    _navigationService.navigateTo(Routes.TicketDetailsViewRoute(id: id));
  }

  navigateToTicketSelectionView(String id) {
    _navigationService.navigateTo(Routes.TicketSelectionViewRoute(id: id));
  }

  navigateToTicketPurchaseView({required String eventID, required String ticketJSONData}) {
    _navigationService.navigateTo(Routes.TicketPurchaseViewRoute(id: eventID, ticketsToPurchase: ticketJSONData));
  }

  navigateToTicketPurchaseSuccessView(String email) {
    _navigationService.replaceWith(Routes.TicketsPurchaseSuccessViewRoute(email: email));
  }

  ///STREAMS
  navigateToLiveStreamView(String id) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.LiveStreamViewRoute(id: id));
  }

  navigateToLiveStreamHostView(String id) {
    _navigationService.navigateTo(Routes.LiveStreamHostViewRoute(id: id));
  }

  navigateToLiveStreamViewerView(String id) {
    _navigationService.navigateTo(Routes.LiveStreamViewerViewRoute(id: id));
  }

  navigateToCreateLiveStreamView(String id) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.CreateLiveStreamViewRoute(id: id, promo: "0"));
  }

  navigateToCreateLiveStreamViewRouteWithPromo(String id, String promo) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.CreateLiveStreamViewRoute(id: id, promo: promo));
  }

  ///VIDEO
  navigateToStandardVideoPlayer(String id) {
    _navigationService.navigateTo(Routes.StandardVideoPlayerViewRoute(id: id));
  }

  navigateToExpandedLandscapeMiniPlayer(String id) {
    _navigationService.navigateTo(Routes.ExpandedLandscapeMiniPlayerViewRoute(id: id));
  }

  ///USERS
  navigateToCurrentUserView() {
    AppBaseViewModel _appBaseViewModel = locator<AppBaseViewModel>();
    _appBaseViewModel.setNavBarIndex(4);
    _navigationService.pushNamedAndRemoveUntil(Routes.AppBaseViewRoute(page: "4"));
  }

  navigateToUserView(String id) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.UserProfileView(id: id));
  }

  ///WALLET
  navigateToWalletView() {
    AppBaseViewModel _appBaseViewModel = locator<AppBaseViewModel>();
    _appBaseViewModel.setNavBarIndex(3);
    _navigationService.pushNamedAndRemoveUntil(Routes.AppBaseViewRoute(page: "3"));
  }

  ///EARNINGS
  navigateToSetUpInstantDepositView() {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.SetUpInstantDepositViewRoute);
  }

  navigateToSetUpDirectDepositView() {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.SetUpDirectDepositViewRoute);
  }

  navigateToUSDBalanceHistoryView() {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.USDBalanceHistoryViewRoute);
  }

  ///SEARCH
  navigateToSearchView() {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateWithTransition(SearchView(), transition: 'fade', opaque: true);
  }

  navigateToSearchViewWithTerm(String term) {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateWithTransition(SearchView(term: term), transition: 'fade', opaque: true);
  }

  ///NOTIFICATIONS
  navigateToNotificationsView() {
    _miniVideoPlayerViewModel.dismissMiniPlayer();
    _navigationService.navigateTo(Routes.NotificationsViewRoute);
  }
}
