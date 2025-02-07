import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;


class SendAfeedBackStaff extends StatefulWidget {
  const SendAfeedBackStaff({super.key});

  @override
  State<SendAfeedBackStaff> createState() => _SendAfeedBackStaffState();
}

class _SendAfeedBackStaffState extends State<SendAfeedBackStaff> {
  int _selectedStar = 0;
 final Set<String> _selectedFeedbacks = {};
 bool isLoading = false;

  Future<void> sendFeedBack() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    try {
      String apiUrl = 'https://your-api-endpoint.com/upload';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Content-Type': 'multipart/form-data',
      });
      request.fields['stars'] = (_selectedStar).toString();
      request.fields['feedback'] = _selectedFeedbacks.toList().toString();

      print("Posting data:");
      print("Stars: ${_selectedStar}");
      print("Feedback: ${_selectedFeedbacks.toList()}");

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Data submitted successfully');
        _clearSelections(); // Clear stars and selected containers

        _showCongratsPopup(); // Show congrats popup
      } else {
        print('Failed to submit data. Status code: ${response.statusCode}');
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error during data submission: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearSelections() {
    setState(() {
      _selectedStar = 0;
      _selectedFeedbacks.clear();
    });
  }

  void _showCongratsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      // barrierColor:Colors.transparent,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Container(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  "Thank you for leaving\nyour feedback",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          toolbarHeight: 70,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: HeaderRow(Icons.arrow_back)),
              Text(
                "Send A FeedBack",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => StaffCurveNabBar()));
                  },
                  child: HeaderRow(Icons.home)),
            ],
          ),
        ),
        body: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Rate Your Experience",
          style: TextStyle(
            fontSize: 28,
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Are You Satisfied with this service?",
          style: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: 18,
          ),
        ),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStar = index + 1;
                });
                print('Selected star index: ${index + 1}');
              },
              child: Icon(
                Icons.star,
                color: index < _selectedStar ? AppColors.navButtonColor : Colors.grey,
                size: 40,
              ),
            );
          }),
        ),
        SizedBox(height: 32),
        Text(
          "Tell us what can be improved?",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChooseContainer("Overall Service"),
            SizedBox(width: 16),
            ChooseContainer("Customer Support"),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChooseContainer("Speed and Efficiency"),
            SizedBox(width: 16),
            ChooseContainer("Repair Quality"),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChooseContainer("App Functional Maintanance"),
            SizedBox(width: 16),
            ChooseContainer("Transparancy"),
          ],
        ),
        SizedBox(height: 32),
        GestureDetector(
          // onTap: () async {
          //   await sendFeedBack();
          // },
          onTap: () {
            if (_selectedStar == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select a star rating'),
                  backgroundColor: Colors.black,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (_selectedFeedbacks.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select at least one feedback option'),
                  backgroundColor: Colors.black,
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              sendFeedBack();
            }
          },
          child: Container(
            height: screenHeight * 0.045,
            width: screenWidth * 0.4,
            decoration: BoxDecoration(
                color: AppColors.navButtonColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: Offset(0, 2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ]),
            child: Center(
              child: isLoading
                  ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  )) // Show loading indicator if _isLoading is true
                  : Text(
                "FeedBack",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget ChooseContainer(String title) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    bool isSelected = _selectedFeedbacks.contains(title);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedFeedbacks.remove(title);
          } else {
            _selectedFeedbacks.add(title);
          }
        });
      },
      child: Container(
        height: screenHeight * 0.045,
        // width: screenWidth * 0.45,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navOpacity : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            width: 0.2,
            color: AppColors.navButtonColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left:15.0,right: 15),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
