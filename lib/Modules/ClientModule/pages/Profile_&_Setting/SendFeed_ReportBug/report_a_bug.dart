import 'dart:io';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/pages/Profile_&_Setting/ClientSettings.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import 'package:c9_app/utils/utils.dart'; // Assuming Utils is a custom utility class for showing messages, etc.

class ReportABug extends StatefulWidget {
  const ReportABug({super.key});

  @override
  State<ReportABug> createState() => _ReportABugState();
}

class _ReportABugState extends State<ReportABug> {
  bool isLoading = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  List<File> _imageFiles = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();

    if (selectedImages != null) {
      setState(() {
        _imageFiles = selectedImages.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> postData() async {
    // String emailPattern =
    //     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    // RegExp regex = RegExp(emailPattern);
    //
    // if (_emailController.text.isEmpty) {
    //   Utils.flushBarErrorMessage('Please fill email fields', context);
    //   return;
    // }
    //
    // if (!regex.hasMatch(_emailController.text)) {
    //   Utils.flushBarErrorMessage('Please enter a valid email address', context);
    //   return;
    // }
    String emailPattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\.[a-zA-Z]{2,})?$";
    RegExp regex = RegExp(emailPattern);

    if (_emailController.text.isEmpty) {
      Utils.flushBarErrorMessage('Please fill email fields', context);
      return;
    }

    if (!regex.hasMatch(_emailController.text)) {
      Utils.flushBarErrorMessage('Please enter a valid email address', context);
      return;
    }

    if (_descriptionController.text.isEmpty) {
      Utils.flushBarErrorMessage('Please fill description fields', context);
      return;
    }
    if (_imageFiles.isEmpty) {
      Utils.flushBarErrorMessage('Please select at least one image', context);
      return;
    }

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

      request.fields['email'] = _emailController.text;
      request.fields['report'] = _descriptionController.text;

      for (int i = 0; i < _imageFiles.length; i++) {
        request.files.add(
          await https.MultipartFile.fromPath(
            'new_file_names[$i]',
            _imageFiles[i].path,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        Utils.flushBarSuccessMessage('Data submitted successfully', context);
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientSettings(),
            ),
          );
        });
        clearReport();
      } else {
        Utils.flushBarErrorMessage('Failed to submit data', context);
        print('Failed to submit data. Status code: ${response.statusCode}');
        print(response.reasonPhrase);
      }
    } catch (e) {
      Utils.flushBarErrorMessage('Error during data submission', context);
      print('Error during data submission: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void clearReport() {
    _emailController.clear();
    _descriptionController.clear();
    _imageFiles.clear();
    setState(() {
      isLoading = false;
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
                "Report A Bug",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClientCurveNabBar()));
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
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      children: [
        //Email
        CustomContainer(
          titleText: 'Email',
          titleText2: "Enter your email",
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          focusNode: emailFocusNode,
          focusCurrent: emailFocusNode,
          focusNext: descriptionFocusNode,
        ),
        SizedBox(height: screenHeight * .013,),
        //Details
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
        ),
        Container(
          height: screenHeight * 0.15,
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.2),
            border: Border.all(
              color: AppColors.navButtonColor.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            controller: _descriptionController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            focusNode: descriptionFocusNode,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            ),
          ),
        ),
        SizedBox(height: screenHeight * .013,),

        Container(
          height: screenHeight * 0.15,
          width: screenWidth * 0.95,
          color: Colors.grey[200],
          child: Stack(
            children: [
              _imageFiles.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageFiles.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.file(
                          _imageFiles[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _imageFiles.removeAt(index);
                            });
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
                  : Center(child: Text("No images selected")),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.camera_alt_outlined, color: Colors.black,),
                  onPressed: _pickImages,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * .013,),

        GestureDetector(
          onTap: () async {
            postData();
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
                "Send",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget CustomContainer({
    required String titleText,
    required String titleText2,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required FocusNode focusNode,
    FocusNode? focusCurrent,
    FocusNode? focusNext,
    String? errorMessage,
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      children: [
        SizedBox(
          height: screenHeight * .013,
        ),
        // For TitleText
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                titleText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )),
        ),
        Container(
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.2),
            border: Border.all(
              color: AppColors.navButtonColor.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              focusNode: focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                // hintText: titleText2,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              ),
              onFieldSubmitted: (value) {
                if (focusCurrent != null && focusNext != null) {
                  Utils.fieldFocusChange(context, focusCurrent, focusNext);
                }
              },
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty) // Render error message only if not empty
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }

}
