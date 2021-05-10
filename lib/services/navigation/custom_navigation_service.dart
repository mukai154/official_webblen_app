import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/app/app.router.dart';
import 'package:webblen/ui/views/base/app_base_view_model.dart';
import 'package:webblen/ui/views/search/search_view.dart';

class CustomNavigationService {
  NavigationService _navigationService = locator<NavigationService>();

  navigateBack() {
    _navigationService.back();
  }

  navigateToBase() {
    _navigationService.pushNamedAndRemoveUntil(Routes.AppBaseViewRoute);
  }

  ///AUTH
  navigateToAuthView() {
    _navigationService.pushNamedAndRemoveUntil(Routes.AuthViewRoute);
  }

  ///ONBOARDING
  navigateToOnboardingView() {
    _navigationService.pushNamedAndRemoveUntil(Routes.OnboardingPathSelectViewRoute);
  }

  ///POSTS
  navigateToPostView(String id) {
    _navigationService.navigateTo(Routes.PostViewRoute(id: id));
  }

  navigateToCreatePostView(String id) {
    _navigationService.navigateTo(Routes.CreatePostViewRoute(id: id, promo: "0"));
  }

  navigateToCreatePostViewWithPromo(String id, String promo) {
    _navigationService.navigateTo(Routes.CreatePostViewRoute(id: id, promo: promo));
  }

  ///EVENTS
  navigateToEventView(String id) {
    _navigationService.navigateTo(Routes.EventViewRoute(id: id));
  }

  navigateToCreateEventView(String id) {
    _navigationService.navigateTo(Routes.CreateEventViewRoute(id: id, promo: "0"));
  }

  navigateToCreateEventViewWithPromo(String id, String promo) {
    _navigationService.navigateTo(Routes.CreateEventViewRoute(id: id, promo: promo));
  }

  ///TICKETS
  navigateToMyTicketsView() {
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
    _navigationService.navigateTo(Routes.LiveStreamViewRoute(id: id));
  }

  navigateToLiveStreamHostView(String id) {
    _navigationService.navigateTo(Routes.LiveStreamHostViewRoute(id: id));
  }

  navigateToLiveStreamViewerView(String id) {
    _navigationService.navigateTo(Routes.LiveStreamViewerViewRoute(id: id));
  }

  navigateToCreateLiveStreamView(String id) {
    _navigationService.navigateTo(Routes.CreateLiveStreamViewRoute(id: id, promo: "0"));
  }

  navigateToCreateLiveStreamViewRouteWithPromo(String id, String promo) {
    _navigationService.navigateTo(Routes.CreateLiveStreamViewRoute(id: id, promo: promo));
  }

  ///USERS
  navigateToCurrentUserView() {
    AppBaseViewModel _appBaseViewModel = locator<AppBaseViewModel>();
    _navigationService.pushNamedAndRemoveUntil(Routes.AppBaseViewRoute);
    _appBaseViewModel.setNavBarIndex(3);
  }

  navigateToUserView(String id) {
    _navigationService.navigateTo(Routes.UserProfileView(id: id));
  }

  ///WALLET
  navigateToWalletView() {
    AppBaseViewModel _appBaseViewModel = locator<AppBaseViewModel>();
    _navigationService.pushNamedAndRemoveUntil(Routes.AppBaseViewRoute);
    _appBaseViewModel.setNavBarIndex(2);
  }

  ///EARNINGS
  navigateToSetUpInstantDepositView() {
    _navigationService.navigateTo(Routes.SetUpInstantDepositViewRoute);
  }

  navigateToSetUpDirectDepositView() {
    _navigationService.navigateTo(Routes.SetUpDirectDepositViewRoute);
  }

  ///SEARCH
  navigateToSearchView() {
    _navigationService.navigateWithTransition(SearchView(), transition: 'fade', opaque: true);
  }

  navigateToSearchViewWithTerm(String term) {
    _navigationService.navigateWithTransition(SearchView(term: term), transition: 'fade', opaque: true);
  }

  ///NOTIFICATIONS
  navigateToNotificationsView() {
    _navigationService.navigateTo(Routes.NotificationsViewRoute);
  }
}
