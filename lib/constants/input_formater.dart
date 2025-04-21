import 'package:flutter/services.dart';

class CnicMaskTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;
    String oldText = oldValue.text;

    // Remove all non-numeric characters from both new and old values
    String digitsOnly = newText.replaceAll(RegExp(r'[^0-9]'), '');
    String oldDigitsOnly = oldText.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit the length to 13 digits
    if (digitsOnly.length > 13) {
      digitsOnly = digitsOnly.substring(0, 13);
    }
    // Create the masked text by adding '-' in the correct places
    StringBuffer maskedText = StringBuffer();
    int selectionIndex = newValue.selection.end;
    int digitsIndex = 0;

    for (int i = 0; i < digitsOnly.length; i++) {
      if (digitsIndex == 5 || digitsIndex == 12) {
        maskedText.write('-');
        if (i < selectionIndex) {
          selectionIndex++;
        }
      }
      maskedText.write(digitsOnly[i]);
      digitsIndex++;
    }

    // Adjust the selection index by comparing changes between old and new values
    int nonDigitChange = newText.length - digitsOnly.length;
    int selectionOffset = newValue.selection.end - oldValue.selection.end;
    int diff = digitsOnly.length - oldDigitsOnly.length;

    if (diff > 0 && selectionOffset > 0 && nonDigitChange > 0) {
      // If the user added a digit, adjust the cursor forward
      selectionIndex = newValue.selection.end +
          (selectionIndex - newValue.selection.end) +
          1;
    } else if (diff < 0 && selectionOffset < 0 && nonDigitChange < 0) {
      // If the user deleted a digit, adjust the cursor backward
      selectionIndex = newValue.selection.end +
          (selectionIndex - newValue.selection.end) -
          1;
    }

    // Ensure the selection index is within valid bounds
    selectionIndex = selectionIndex.clamp(0, maskedText.length);

    return TextEditingValue(
      text: maskedText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

var numberInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
];
Map<String, List<Map<String, String>>> faqs = {
  "faqs": [
    {
      'question': "Q1. Where can I get M-Tag for my vehicle?",
      'ans':
          '''M-Tag can be acquired by visiting the nearest registration and recharge facility on the toll plazas. M-Tag registration locations on M-2 include Islamabad M-2 entry, Bhera, Sialmor, Pindi Bhattiya Entry, Shekhupura, Kalashah Kaku, and Ravi. Please call 1313 for more information.''',
    },
    {
      'question':
          "Q2. How to get M-Tag, Can I register multiple M-Tags on 1 CNIC?",
      'ans':
          "You only have to bring your Vehicle, vaccination certificate, and original CNIC. Yes, you can register multiple M-Tags for different cars on one CNIC."
    },
    {
      'question': "Q3. What Is 1313?",
      'ans':
          '1313 is helpline of M-Tag which is available for 24/7 to facilitate the customers. Customer can change their ownership by calling 1313 helpline and can also cancel their M-Tag. '
    },
    {
      'question':
          "Q4. Is it mandatory to get M-Tag for traveling on all motorways? ",
      'ans':
          "Dear Customer, in light of Lahore High Court decision it is mandatory to get M-Tag for traveling through all toll plazas linking with the Ravi toll plaza. Please call 1313 for more information. "
    },
    {
      'question': "Q5. How to recharge M-Tag?",
      'ans':
          "You can recharge your M-Tag by visiting the nearest recharge and registration booth on toll plazas or online services like easy paisa, jazz cash, or U-bank. M-Tag mobile application “M-Tag One Network” is also available for recharge. Please call 1313 for more information."
    },
    {
      'question': "Q6. What is the M-Tag mobile application useful for?",
      'ans':
          "M-Tag one network mobile application can be used for recharge, toll history check, balance check, toll calculation, and feedback. You can also Cancel your M-Tag through Application. Please call 1313 for more information. "
    },
    {
      'question':
          "Q7. Can the M-Tag of a car registered with a previous owner be shifted to my name and credentials? ",
      'ans':
          "Yes, the M-Tag of a purchased car can be shifted to new credentials by calling 1313 and verifying the new information. "
    },
    {
      'question': "Q8. How to cancel my M-tag account? ",
      'ans':
          "M-tag account can be canceled by calling through recorded helpline 1313 or can also be cancelled through M-Tag One Network Application."
    },
    {
      'question':
          "Q9. What is the location of the Mobile Registration Unit for today?",
      'ans':
          "Dear Customer, our mobile registration unit is currently assisting in operations on main toll plazas at M-2 Motorway, however, any changes will be disseminated on our social media beforehand. Please call 1313 for more information or email us at conncet@onenetwork.pk "
    },
    {
      'question':
          "Q10. I am not receiving One-time Password (OTP) for my M-Tag One Network application?",
      'ans':
          '''Dear customer, please confirm if your number is ported to a different network or not? Please mention your CNIC, PHONE NUMBER, and MOBILE NETWORK, so we can resolve this issue. Please dial 1313 for any other queries or assistance'''
    },
    {
      'question':
          "Q11. I cannot download M-Tag One network application on my phone?",
      'ans':
          '''Please check region settings from play store and set the location of the region to Pakistan. Try installing the application again. If the problem persists, please email us at connect@onenetwork.pk'''
    },
    {
      'question': "Q12. I Want to get blocked M-Tag ID un-blocked?",
      'ans':
          '''Please inbox us your M-Tag ID, CNIC, vehicle number and phone number so we can check for discrepancies due to which our system flagged your Id. Please call 1313 for more information.'''
    },
    {
      'question': "Q13. Blocked M-Tag account?",
      'ans':
          '''Dear customer, M-Tags are generally blocked by the system due to detections of unusual or fraudulent activity at the time of the internal system audit. It takes a while to identify the reason for the M-Tag blockage and in case of fraudulent activity, the M-Tag remains blocked until a case is generated to get it unblocked.'''
    },
    {
      'question': "Q14. How to update Credentials?",
      'ans':
          '''Dear Sir, please call our 24/7 helpline "1313" in order to update your credentials. Provide your M-tag ID, Cnic, Phone Number, and Vehicle registration number. Feel free to reach out at connect@onenetwork.pk if you need further assistance.'''
    },
    {
      'question': "Q15. Credentials already exist during app login/signup?",
      'ans':
          '''Dear customer, please provide the following details:\nCnic\nMobile number'''
    },
    {
      'question':
          "Q16. I have entered wrong credentials entered during application sign-up?",
      'ans': 'Dear Customer, please provide us your '
          'Correct Mobile number  CNIC  '
          'wrong/previously entered Mobile number CNIC '
    },
    {
      'question':
          "Q17. M-tag One Network application not available in your region/country error?",
      'ans':
          '''Dear Sir/Madam, please check the region settings from the Google Play store and set the location of the region to Pakistan. Try installing the application again. If the problem persists, please call 1313 for further assistance or email at connect@onenetwork.pk'''
    },
    {
      'question': "Q18. Blocked M-Tag query?",
      'ans':
          '''Dear customer, M-Tags are used for Automatic vehicle identification at entry and exits and Cashless Toll-Tax collection. The system audits are performed in intervals and M-Tags that are counterfeited by the customers at the entry to evade Toll Tax are blocked by the system. In such cases, the M-Tag shall remain blocked. We reserve the right to report the customer to Police and initiate a case against the said Tax evasion. Please provide your M-Tag ID so we may check the reason for M-Tag blockage.'''
    },
    {
      'question': "Q19. I want to apply to One Network?",
      'ans':
          '''To apply in one network send your resume to recruitement@onenetwork.pk '''
    },
    {
      'question': "Q20. Standard response for Complaints on Social Media?",
      'ans':
          '''Dear Customer, Inconvenience faced by you is highly regretted, please share your Complete details (Issue, M-Tag ID &amp; Vehicle number, cnic, Phone number) in DM/Inbox and our customer representative will resolve your issue as soon as possible'''
    },
    {
      'question': "Q21. How to remove your account?",
      'ans':
          '''\u2022 If your CNIC is incorrect, please call 1313.\n\u2022 If your Mobile Number is incorrect, please call 1313.\n\u2022 If you need any kind of help please call 1313.\n\u2022 You want to deactivate your account.'''
    },
  ],
};
