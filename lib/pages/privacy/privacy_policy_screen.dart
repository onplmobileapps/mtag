import 'package:flutter/material.dart';

import '../../widgets/privacy_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadiusDirectional.only(
              topEnd: Radius.circular(15),
              topStart: Radius.circular(15),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrivacyPolicySection(
                    title: "Overview",
                    content:
                        "One Network (PVT) Limited built the M-Tag One Network app as a Free app. This SERVICE is provided by One Network (PVT) Limited at no cost and is intended for use as is.This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service.If you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which are accessible at M-Tag One Network unless otherwise defined in this Privacy Policy.",
                  ),
                  PrivacyPolicySection(
                    title: "Information Collection and Use",
                    content:
                        "For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to Nothing.\nThe information that we request will be retained by us and used as described in this privacy policy.The app does use third-party services that may collect information used to identify you.",
                  ),
                  PrivacyPolicySection(
                    title: "Log Data",
                    content:
                        "We want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third-party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.",
                  ),
                  PrivacyPolicySection(
                    title: "Cookies",
                    content:
                        "Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory. This Service does not use these (cookies) explicitly. However, the app may use third-party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.",
                  ),
                  PrivacyPolicySection(
                    title: "Service Providers",
                    content:
                        "We may employ third-party companies and individuals due to the following reasons:To facilitate our Service;To provide the Service on our behalf;To perform Service-related services; orTo assist us in analyzing how our Service is used.\nWe want to inform users of this Service that these third parties have access to their Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.",
                  ),
                  PrivacyPolicySection(
                      title: "Security",
                      content:
                          "We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security."),
                  PrivacyPolicySection(
                      title: "Links to Other Sites",
                      content:
                          "This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services."),
                  PrivacyPolicySection(
                      title: "Children’s Privacy",
                      content:
                          "These Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13 years of age. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do the necessary actions."),
                  PrivacyPolicySection(
                      title: "Changes to This Privacy Policy",
                      content:
                          "These Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13 years of age. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do the necessary actions."),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
