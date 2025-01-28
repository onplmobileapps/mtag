import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:mtag_flutterapp/base/app_data.dart';

class Analytics {
  static String dateTime = "";
  static String fcmToken = "";
  static FirebaseAnalytics? firebaseAnalytics;

  static Future<void> initialize() async {
    firebaseAnalytics = FirebaseAnalytics.instance;
    dateTime = getDate();
    fcmToken = AppData.getFcmToken().toString();
  }

  static String getDate() {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}";

    return formattedDate;
  }

  static void logEvent(String eventName, Map<String, Object> parameters) {
    if (!kDebugMode) {
      firebaseAnalytics?.logEvent(name: eventName, parameters: parameters);
    } else {
      debugPrint("App is in debug mode");
    }
  }

//........................................................sign in events
  static void loginScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime};
    logEvent("Login_Screen_Displayed", b);
  }

  static void signInTapped() {
    Map<String, Object> b = {"DateTime": dateTime};
    logEvent("Sign_In_Tapped", b);
  }

  static void biometricSignInTapped() {
    Map<String, Object> b = {"DateTime": dateTime};
    logEvent("Biometric_Sign_In_Tapped", b);
  }

  //........................................................sign up events
  static void signUpOnLoginPageTapped() {
    Map<String, Object> b = {"DateTime": dateTime};
    logEvent("Sign_Up_onLoginPage_Tapped", b);
  }

  static void signupScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime};
    logEvent("Signup_Screen_Displayed", b);
  }

  static void signUpTapped() {
    Map<String, Object> b = {"DateTime": dateTime};
    logEvent("Sign_Up_Tapped", b);
  }

  static void signInOnSignUpPageTapped() {
    Map<String, Object> b = {"DateTime": dateTime};
    logEvent("Sign_In_onSignUpPage_Tapped", b);
  }

  //........................................................verification events
  static void verificationCodeSent() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Verification_Code_Sent", b);
  }

  static void verifyCodeSuccessful() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Verify_Code_Successful", b);
  }

  static void verifyCodeFailed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Verify_Code_Failed", b);
  }

  static void resendVerificationCodeTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Resend_Verfication_Code_Tapped", b);
  }

  //........................................................Dashboard events
  static void dashboardScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Dashboard_Screen_Displayed", b);
  }

  static void myMTagTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("My_M_Tag_Tapped", b);
  }

  static void transactionsTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Transactions_Tapped", b);
  }

  static void rechargeTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Recharge_Tapped", b);
  }

  static void tollCalculatorTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Toll_Calculator_Tapped", b);
  }

  static void feedbackTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Feedback_Tapped", b);
  }

  static void activitiesTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Activities_Tapped", b);
  }

  static void userProfileTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("User_Profile_Tapped", b);
  }

  static void notificationTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Notification_Tapped", b);
  }

  static void callWhatsappTap() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("callWhatsapp_Tap", b);
  }

  static void smsAlertsTap() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("smsAlerts_Tap", b);
  }

  //........................................................My M-Tag Screen events
  static void myMTagScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("My_M_Tag_Screen_Displayed", b);
  }

  static void selectedMTag(String mtagId) {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken, "mtagID": mtagId};
    logEvent("Selected_M_Tag", b);
  }

  //........................................................Vehicle Detail Screen events
  static void vehicleDetailScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Vehicle_Detail_Screen_Displayed", b);
  }

  static void rechargeOnVehicleDetailScreenTapped(String mtagId) {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken, "mtagID": mtagId};
    logEvent("Recharge_on_Vehicle_Detail_Screen_Tapped", b);
  }

  //........................................................History Screen events
  static void historyScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("History_Screen_Displayed", b);
  }

  static void viewTransactionHistory(String tapValue) {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken, "Value Tapped": tapValue};
    logEvent("View_Transaction_History", b);
  }

  static void filterTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Filter_Tapped", b);
  }

  //........................................................Toll Calculator Screen events
  static void tollCalculatorScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Toll_Calculator_Screen_Displayed", b);
  }

  //........................................................Submit Feedback Screen events
  static void submitFeedbackScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Submit_Feedback_Screen_Displayed", b);
  }

  static void submitFeedbackTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Submit_Feedback_Tapped", b);
  }

  static void call1313Tapped() {
    Map<String, Object> b = {"DateTime": dateTime};
    logEvent("Call_1313_Tapped", b);
  }

  //........................................................Your Activities Screen events
  static void yourActivitiesScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime};
    logEvent("Your_Activities_Screen_Displayed", b);
  }

  //........................................................Profile Screen events

  static void profileScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Profile_Screen_Displayed ", b);
  }

  static void updateProfile() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Update_Profile", b);
  }

  //........................................................Recharge M-Tag Screen events
  static void rechargeMTagScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Recharge_M_Tag_Screen_Displayed", b);
  }

  static void rechargeAmountSelected(String amount) {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken, "amount": amount};
    logEvent("Recharge_Amount_Selected", b);
  }

  // Card Detail Screen Displayed event
  static void cardDetailScreenDisplayed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Card_Detail_Screen_Displayed", b);
  }

  // Select Saved Card event
  static void selectSavedCard() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Select_Saved_Card", b);
  }

  // Add New Card Tapped event
  static void addNewCardTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Add_New_Card_Tapped", b);
  }

  // Recharge Successful event
  static void rechargeSuccessful() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Recharge_Successful", b);
  }

  // Recharge Failed event
  static void rechargeFailed() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Recharge_Failed", b);
  }

  // Recharge Canceled event
  static void rechargeCanceled() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Recharge_Canceled", b);
  }

  // Credit Debit Tapped event
  static void creditDebitTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Credit_Debit_Tapped", b);
  }

  // Jazz Cash Tapped event
  static void jazzCashTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Jazz_Cash_Tapped", b);
  }

//......................................................................subscribe events

  static void subscribeTapped() {
    Map<String, Object> b = {"DateTime": dateTime, "User_Token": fcmToken};
    logEvent("Subscribe_Tapped", b);
  }
}
