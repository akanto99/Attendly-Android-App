import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsStaff extends StatefulWidget {
  const AboutUsStaff({super.key});

  @override
  State<AboutUsStaff> createState() => _AboutUsStaffState();
}

class _AboutUsStaffState extends State<AboutUsStaff> {
  String _urlins = "";
  String _urlfb ="";
  String _urllinks = "";
  Color facebookColor = Colors.black;
  Color linkdinColor = Colors.black;
  Color instragramColor = Colors.black;
  // Color facebookColor = AppColors.navButtonColor;
  // Color linkdinColor = AppColors.navButtonColor;
  // Color instragramColor = AppColors.navButtonColor;

  void selectSocialMedia(String platform, String url) async {
    setState(() {
      facebookColor = Colors.black;
      linkdinColor = Colors.black;
      instragramColor = Colors.black;

      if (platform == 'facebook') {
        facebookColor = Colors.blue;
      } else if (platform == 'linkdin') {
        linkdinColor = Colors.blue;
      } else if (platform == 'instragram') {
        instragramColor = Colors.blue;
      }
    });

    await launch(url);
  }
  UniqueKey item1Key = UniqueKey();
  UniqueKey item2Key = UniqueKey();
  UniqueKey item3Key = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ResPonsiveUi(
          mobile: body(context),
          desktop: body(context),
          tablet: body(context),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10,bottom: 10),
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: HeaderRow(Icons.arrow_back)),
                    Text(
                      "About us", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StaffCurveNabBar()));
                        },
                        child: HeaderRow(Icons.home)),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Container(
                  height: screenHeight * 0.15,
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                    color: Color(0xffFFF9DD).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1.0, color: AppColors.navButtonColor),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greyOpacity,
                        offset: Offset(0, 2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    image: DecorationImage(
                        image: AssetImage(
                          "images/staff/settingsIcon/c9img.jpeg",
                        ),
                        fit: BoxFit.fill),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Text(
                  "History",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Container(
                  height: screenHeight * 0.15,
                  width: screenWidth * 0.95,
                  // decoration: BoxDecoration(
                  //   // color: Color(0xffFFF9DD).withOpacity(0.5),
                  //   borderRadius: BorderRadius.circular(10),
                  //   border: Border.all(width: 1.0,
                  //       color: AppColors.navButtonColor),
                  // ),
                  child: AutoSizeText(
                      "C9 Recruitment are headquartered in London,UK. Originally established in 2019, we were inspired by the latest technologies\n in the cloud infrastructure sector to use our skillset to streamline the recruitment process. This has eventually evolved into many divisions, such as recruitment, migrations, telephony, and various other lines of business."),
                ),

                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Container(
                  height: screenHeight * 0.25,
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                    color: Color(0xffFFF9DD).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1.0, color: AppColors.navButtonColor),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greyOpacity,
                        offset: Offset(0, 2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    image: DecorationImage(
                        image: AssetImage(
                          "images/staff/settingsIcon/faq.jpg",
                        ),
                        fit: BoxFit.cover),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Freequently Ask Questions",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    key: item1Key,
                    onExpansionChanged: (expanded) {
                      if (expanded == true) {
                        setState(() {
                          item2Key = UniqueKey();
                          item3Key = UniqueKey();
                        });
                      }
                    },
                    title: Text("What does C9 Recruitment company do?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              "C9 Recruitment's objective is to streamline the recruitment process through automation and digital signage. They enable companies to focus on their objectives by efficiently managing resourcing needs, ensuring cost-effectiveness, and progressing projects to their standards, providing peace of mind."),
                        ) ),
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    key: item2Key,
                    onExpansionChanged: (expanded) {
                      if (expanded == true) {
                        setState(() {
                          item1Key = UniqueKey();
                          item3Key = UniqueKey();
                        });
                      }
                    },
                    title: Text("What services does C9 Technology offer?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              "C9 Technology offers a wide range of services, including logistics, technology, pharmaceutical, sales/call centre staffing, marketing, and managerial services." ),
                        )),
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    key: item3Key,
                    onExpansionChanged: (expanded) {
                      if (expanded == true) {
                        setState(() {
                          item1Key = UniqueKey();
                          item2Key = UniqueKey();
                        });
                      }
                    },
                    title: Text("Why is C9 Recruitment suitable for you?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                          "C9 Technology is suitable for you because it provides multi-award-winning recruitment services with consultants across the UK. They specialize in IT & logistics recruitment, serving over 100 clients in various sectors such as logistics, charity, education, finance, government, housing, professional services, property & construction, social care & health, and technology."),
                        )  ),
                    ],
                  ),
                ),
                // Text(
                //   "Developer Sections",
                //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                // ),
                // SizedBox(
                //   height: screenHeight * 0.013,
                // ),
                // Container(
                //   height: screenHeight * 0.15,
                //   width: screenWidth * 0.93,
                //   decoration: BoxDecoration(
                //     color: AppColors.whiteColor,
                //     borderRadius: BorderRadius.circular(5),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.3),
                //         offset: Offset(0, 5),
                //         blurRadius: 10,
                //         spreadRadius: 5,
                //       ),
                //     ],
                //   ),
                //   child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: AutoSizeText(
                //           "This application is developed by Prospect Engine LLC, a software developer company located at House 02, Road No. 12A, Dhaka 1230. They specialize in accelerating sales through inbound and outbound lead generation strategies, emphasizing SEO, personal branding, and LinkedIn outreach, while promoting teamwork and a comprehensive growth blueprint.")),
                // ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Container(
                  height: 100,
                  width: 100,
                  child:
                  Image.asset('images/c9Profile.png', ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => selectSocialMedia('facebook', _urlfb),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: facebookColor,
                            border: Border.all(
                                color: Colors.blue.shade300,
                                width: 1
                            )
                        ),
                        child: Icon(
                          Icons.facebook,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    SizedBox(width: 10,),

                    GestureDetector(
                      onTap: () =>
                          selectSocialMedia('linkdin', _urllinks),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: linkdinColor,
                            border: Border.all(
                                color: Colors.blue.shade300,
                                width: 1
                            )
                        ),
                        child: Icon(
                          Icons.link,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    GestureDetector(
                      onTap: () => selectSocialMedia('instragram', _urlins),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: instragramColor,
                            border: Border.all(
                                color: Colors.blue.shade300,
                                width: 1
                            )
                        ),
                        child: Icon(
                          Icons.mobile_friendly,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Text("Contact Info",style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                ),),
                SizedBox(
                  height: screenHeight * 0.013,
                ),

                FooterText(" contact@c9-recruitment.com"),
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                FooterText("phone: +44 20 8152 4574"),
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                FooterText("Hope House, 1 High Street, Cheshunt, EN8 0BX"),

              ],
            )
            
            
              ],
            ),
          ),
          Container(
            height: 30,
            width: MediaQuery.of(context).size.width,
            color: Colors.blueGrey.shade100,
            child:
            Center(child: Text("Copyright @ 2024 C9 Recruitment.All rights reserved")),
          )
        ],
      ),
    );
  }
  Widget FooterText(String text){
    return Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    );
  }
}
