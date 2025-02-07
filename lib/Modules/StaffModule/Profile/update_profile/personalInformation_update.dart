import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/Profile/staff_profilev2.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PersonalInformationUpdate extends StatefulWidget {
  const PersonalInformationUpdate({super.key});

  @override
  State<PersonalInformationUpdate> createState() => _PersonalInformationUpdateState();
}

class _PersonalInformationUpdateState extends State<PersonalInformationUpdate> {
  String currentDate = "";
  void _getCurrentDate() {
    currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
  }
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _address1Controller = TextEditingController();
  TextEditingController _address2Controller = TextEditingController();
  TextEditingController _townOrCityController = TextEditingController();
  TextEditingController _postCodeController = TextEditingController();
  TextEditingController _ninController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _getCurrentDate();}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffEEF1F5),
        body: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: screenHeight * 0.1,
            decoration: BoxDecoration(
              // color: Color(0xff131A27)
                color: AppColors.navColor),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0,right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container(
                  //   height: screenHeight * 0.06,
                  //   width: screenWidth * 0.12,
                  //   decoration: BoxDecoration(
                  //     image: DecorationImage(image: AssetImage("images/c9LogoLatest.png"), fit: BoxFit.cover),
                  //     color: AppColors.whiteColor,
                  //     // shape: BoxShape.rectangle,
                  //     borderRadius: BorderRadius.circular(10),
                  //
                  //     // color: Colors.red
                  //   ),
                  // ),
                  GestureDetector(
                      onTap: () {
                        // Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfile()));
                      },
                      child: HeaderRow(Icons.arrow_back)),
                  Text(
                    "C9 Recruitment",
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Replace with AppColors.whiteColor if applicable
                    ),
                  ),
                  Text(
                    "$currentDate",
                    style: GoogleFonts.openSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white, // Replace with AppColors.whiteColor if applicable
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.013,
          ),
          Container(
            width: screenWidth,
            child: Center(
              child: AutoSizeText("Personal Information Update",
                maxLines: 1,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(fontSize: 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              width: screenWidth*0.92,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: Offset(0, 2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.013,),
                  CustomTextField(
                    headerText: 'First Name',
                    controller: _firstNameController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter your first name',
                  ),
                  SizedBox(height: screenHeight * 0.013,),
                  CustomTextField(
                    headerText: 'Last Name',
                    controller: _firstNameController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter your last name',
                  ),
                  SizedBox(height: screenHeight * 0.013,),
                  CustomTextField(
                    headerText: 'Email',
                    controller: _firstNameController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter your email address',
                  ),
                  SizedBox(height: screenHeight * 0.013,),
                  CustomTextField(
                    headerText: 'Contact Number',
                    controller: _firstNameController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter your contact number',
                  ),
                  SizedBox(height: screenHeight * 0.013,),
                  CustomTextField(
                    headerText: 'Address Line 1',
                    controller: _firstNameController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter your address line 1',
                  ),
      
                  SizedBox(height: screenHeight * 0.013,),
                  CustomTextField(
                    headerText: 'Address Line 2',
                    controller: _firstNameController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Enter your Address Line 2',
                  ),
                  SizedBox(height: screenHeight * 0.05,),
                  Container(
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.7,
                    decoration: BoxDecoration(
                      color: Color(0xff2664EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          )) // Show loading indicator if isLoading is true
                          : AutoSizeText(
                        "UPDATE",
                        maxLines: 1,
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(fontSize: 16),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.023,),
                ],
              ),
            ),
          )
      
        ],
      ),
    );
  }

 Widget CustomTextField({
    required String headerText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String hintText,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenWidth * 0.85,
          child: AutoSizeText(
            headerText,
            maxLines: 1,
            style: GoogleFonts.openSans(
              textStyle: TextStyle(fontSize: 15),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.013,
        ),
        Container(
          height: screenHeight * 0.055,
          width: screenWidth * 0.85,
          decoration: BoxDecoration(
            color: Color(0xffF2F5F6),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Color(0xffEAECED),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: GoogleFonts.openSans(
              textStyle: TextStyle(fontSize: 15),
              fontWeight: FontWeight.w500,
            ),
            keyboardType: keyboardType,

            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.openSans(
                color: Colors.grey, // Text color
                fontSize: 15, // Font size
                fontWeight: FontWeight.normal, // Font weight
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Add padding here
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

}
