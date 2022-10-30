import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/extensions/dynamic.dart';
import 'package:fuodz/view_models/payment.view_model.dart';
import 'package:fuodz/views/pages/profile/account_delete.page.dart';
import 'package:fuodz/views/pages/splash.page.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/widgets/bottomsheets/referral.bottomsheet.dart';
import 'package:fuodz/widgets/cards/language_selector.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info/package_info.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:share/share.dart';

class ProfileViewModel extends PaymentViewModel {
  //
  String appVersionInfo = "";
  bool authenticated = false;
  User currentUser;

  //
  AuthRequest _authRequest = AuthRequest();

  ProfileViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    //
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    appVersionInfo = "$versionName($versionCode)";
    authenticated = await AuthServices.authenticated();
    if (authenticated) {
      currentUser = await AuthServices.getCurrentUser(force: true);
    }
    notifyListeners();
  }

  /**
   * Edit Profile
   */

  openEditProfile() async {
    final result = await viewContext.navigator.pushNamed(
      AppRoutes.editProfileRoute,
    );

    if (result != null && result) {
      initialise();
    }
  }

  /**
   * Change Password
   */

  openChangePassword() async {
    viewContext.navigator.pushNamed(
      AppRoutes.changePasswordRoute,
    );
  }

//
  openRefer() async {
    await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReferralBottomsheet(this),
    );
  }

  //
  openWallet() {
    viewContext.navigator.pushNamed(
      AppRoutes.walletRoute,
    );
  }

  /**
   * Delivery addresses
   */
  openDeliveryAddresses() {
    viewContext.navigator.pushNamed(
      AppRoutes.deliveryAddressesRoute,
    );
  }

  //
  openFavourites() {
    viewContext.navigator.pushNamed(
      AppRoutes.favouritesRoute,
    );
  }

  /**
   * Logout
   */
  logoutPressed() async {
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.confirm,
      title: "Logout".tr(),
      text: "Are you sure you want to logout?".tr(),
      onConfirmBtnTap: () {
        viewContext.pop();
        processLogout();
      },
    );
  }

  void processLogout() async {
    //
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.loading,
      title: "Logout".tr(),
      text: "Logging out Please wait...".tr(),
      barrierDismissible: false,
    );

    //
    final apiResponse = await _authRequest.logoutRequest();

    //
    viewContext.pop();

    if (!apiResponse.allGood) {
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Logout".tr(),
        text: apiResponse.message,
      );
    } else {
      //
      await AuthServices.logout();
      viewContext.navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    }
  }

  openNotification() async {
    viewContext.navigator.pushNamed(
      AppRoutes.notificationsRoute,
    );
  }

  /**
   * App Rating & Review
   */
  openReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (Platform.isAndroid) {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    } else if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    }
  }

  //
  openPrivacyPolicy() async {
    final url = Api.privacyPolicy;
    openWebpageLink(url);
  }

  openTerms() {
    final url = Api.terms;
    openWebpageLink(url);
  }

  //
  openContactUs() async {
    final url = Api.contactUs;
    openWebpageLink(url);
  }

  openLivesupport() async {
    final url = Api.inappSupport;
    openWebpageLink(url);
  }

  //
  changeLanguage() async {
    showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return AppLanguageSelector();
      },
    );
  }

  openLogin() async {
    await viewContext.navigator.pushNamed(
      AppRoutes.loginRoute,
    );
    //
    initialise();
  }

  void shareReferralCode() {
    Share.share(
      "%s is inviting you to join %s via this referral code: %s".tr().fill(
            [
              currentUser.name,
              AppStrings.appName,
              currentUser.code,
            ],
          ) +
          "\n" +
          AppStrings.androidDownloadLink +
          "\n" +
          AppStrings.iOSDownloadLink +
          "\n",
    );
  }

  //
  deleteAccount() {
    viewContext.nextPage(AccountDeletePage());
  }
}
