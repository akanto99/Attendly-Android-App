import 'dart:convert';
import 'dart:typed_data';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/banking_step6.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/documents_step5.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/driving_step3.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/fitness_step2.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/licExpiry_step4.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/personal_step1.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/addressSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/bankSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/bankSection2.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/confirmationSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/contactSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/personalSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/personalSection2.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/preferencesSection.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../../utils/utils.dart';

class MultiStepView extends StatefulWidget {
  @override
  _MultiStepViewState createState() => _MultiStepViewState();
}

class _MultiStepViewState extends State<MultiStepView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(6, (_) => GlobalKey<FormState>());
  String selectedRole ="";
  String dbsEdbs ="";
  String ukExperience ="";
  String validCPC ="";
  String validTacho ="";
  String currentDate = "";
  void _getCurrentDate() {
    currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedRole();
    _loadData();
    _getCurrentDate();
  }

  Future<void> _loadSelectedRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('selectedRole') ?? "";
    });
    print("Loaded Role: $selectedRole");
  }
  Future<void> _saveSelectedRole(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRole', role);
  }


  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      dbsEdbs = prefs.getString('dbsEdbs') ?? "";
      ukExperience = prefs.getString('ukExperience') ?? "";
      validCPC = prefs.getString('validCPC') ?? "";
      validTacho = prefs.getString('validTacho') ?? "";
    });
    print("Loaded Role: $dbsEdbs");
    print("Loaded Role: $ukExperience");
    print("Loaded Role: $validCPC");
    print("Loaded Role: $validTacho");
  }

  Future<void> _savedbsEdbsData(String dbsEdbs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('dbsEdbs', dbsEdbs);
    await prefs.setString('ukExperience', ukExperience);
    await prefs.setString('validCPC', validCPC);
    await prefs.setString('validTacho', validTacho);
  }
  Future<void> _saveUKData(String ukExperience) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ukExperience', ukExperience);
  }
  Future<void> _saveCPCData(String validCPC) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('validCPC', validCPC);
  }
  Future<void> _saveTachoData(String validTacho) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('validTacho', validTacho);
  }


  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentStep = step;
    });
  }

  ScrollController _scrollController = ScrollController();

  void _PreviousStep() {
  Navigator.pop(context);
  }
  void _BackStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }
  @override
  Widget build(BuildContext context) {
    bool isDriver = selectedRole?.toLowerCase().contains('driver') == true;

    void _onStep1() {
      setState(() {
        _goToStep(1);
      });
    }
    void _onStep2() {
      setState(() {
        _goToStep(2);
      });
    }
    void _onStep3() {
      setState(() {
        _goToStep(3);
      });
    }
    void _onStep4() {
      setState(() {
        isDriver ? _goToStep(4):   _goToStep(3);
      });
    }
    void _onStep5() {
      setState(() {
        isDriver ? _goToStep(5):_goToStep(4);
      });
    }
    void _onStep6() {
      setState(() {
        isDriver ?  _goToStep(6): _goToStep(5);
      });
    }
    final List<IconData> _stepIcons = [
      Icons.work,
      Icons.fitness_center,
      if (isDriver) Icons.rule,
      Icons.delete_forever_outlined,
      Icons.document_scanner_outlined,
      Icons.food_bank,
    ];

    final List<String> _stepLabels = [
      'Personal',
      'Fitness',
      if (isDriver) 'Driving',
      'Expiry',
      'Documents',
      'Banking',
    ];

    final List<Widget> _steps = [
      PersonalStep1(
        scrollController: _scrollController,
        onStep1: _onStep1,
        formKey: _formKeys[0],
        onRoleChange: (role) {setState(() {selectedRole = role;});_saveSelectedRole(role);},
        onDBSChanged: (dbs) {setState(() {dbsEdbs = dbs;});_savedbsEdbsData(dbs);},
      ),
      FitnessStep2(formKey: _formKeys[1],  onStep2: _onStep2,),

      if (isDriver) DrivingStep3(formKey: _formKeys[2],  onStep3: _onStep3,
        onUkExperienceChanged: (uk) {setState(() {ukExperience = uk;});_saveUKData(uk);},
        onValidCPCChanged: (cpc) {setState(() {validCPC = cpc;});_saveCPCData(cpc);},
        onValidTachoChanged: (tacho) {setState(() {validTacho = tacho;});_saveTachoData(tacho);},
      ),


      LicexpiryStep4(formKey: _formKeys[isDriver ? 3 : 2],  onStep4: _onStep4, dbsEdbs:dbsEdbs,ukExperience:ukExperience,validCPC:validCPC,validTacho:validTacho,),
      DocumentsStep5(formKey: _formKeys[isDriver ? 4 : 3],  onStep5: _onStep5),
      BankingStep6(formKey: _formKeys[isDriver ? 5 : 4],  onStep6: _onStep6),
    ];
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
             // Text(dbsEdbs),
            // Text(selectedRole.isNotEmpty ? selectedRole : "No role selected"),
            // const SizedBox(height: 10),
            _currentStep == 0
                ?    Container(
              height: screenHeight * 0.1,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                // color: Color(0xff131A27)
                  color: AppColors.navColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: (){
                        _PreviousStep();
                      },
                      child: HeaderRow(Icons.arrow_back)),
                Column(
                  children: [
                    Container(
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.12,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage("images/c9LogoLatest.png"), fit: BoxFit.cover),
                        color: AppColors.whiteColor,
                        // shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),

                        // color: Colors.red
                      ),
                    ),
                    Text(
                      "Registration",
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Replace with AppColors.whiteColor if applicable
                      ),
                    ),
                  ],
                ),
        Container(
          height: screenHeight * 0.055,
          width: screenWidth * 0.12,)
                ],
              ),
            )
                :  Container(
              height: screenHeight * 0.1,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                // color: Color(0xff131A27)
                  color: AppColors.navColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: (){
                        _BackStep();
                      },
                      child: HeaderRow(Icons.arrow_back)),
                  Column(
                    children: [
                      Container(
                        height: screenHeight * 0.06,
                        width: screenWidth * 0.12,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage("images/c9LogoLatest.png"), fit: BoxFit.cover),
                          color: AppColors.whiteColor,
                          // shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),

                          // color: Colors.red
                        ),
                      ),
                      Text(
                        "Registration",
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Replace with AppColors.whiteColor if applicable
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: screenHeight * 0.055,
                    width: screenWidth * 0.12,)
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_stepIcons.length, (index) {
                bool isCompleted = index < _currentStep;
                bool isCurrent = index == _currentStep;

                return Row(
                  children: [
                    // Add a half-line before "Personal" step
                    if (index == 0)
                      Container(
                        width: MediaQuery.of(context).size.width * 0.03, // Half-length
                        height: 4,
                        color: isCompleted || isCurrent ? Colors.green : AppColors.navColor,
                      ),

                    // Add a full-line before other steps
                    if (index != 0)
                      Container(
                        width: MediaQuery.of(context).size.width * 0.08, // Full-length
                        height: 4,
                        color: isCompleted || isCurrent ? Colors.green : AppColors.navColor,
                      ),

                    // Circle Avatar for Step Icon
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.04,
                      backgroundColor: isCompleted || isCurrent ? Colors.green : AppColors.navColor,
                      child: isCompleted
                          ? const Icon(Icons.check, size: 15, color: Colors.white)
                          : Icon(
                        _stepIcons[index],
                        size: 15,
                        color: isCurrent ? Colors.white : Colors.white70,
                      ),
                    ),

                    // Add a half-line at the end after "Banking" step
                    if (index == _stepIcons.length - 1)
                      Container(
                        width: MediaQuery.of(context).size.width * 0.03, // Half-length
                        height: 4,
                        color: AppColors.navColor,
                      ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_stepLabels.length, (index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.16,
                  alignment: Alignment.center,
                  child: Text(
                    _stepLabels[index],
                    style: TextStyle(
                      fontSize: 11,
                      color: index <= _currentStep ? Colors.green : AppColors.navColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _steps,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

