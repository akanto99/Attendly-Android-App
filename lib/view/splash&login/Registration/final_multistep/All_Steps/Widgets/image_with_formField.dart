// import 'package:c9_app/res/color.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class CustomImagePickerWithFormField extends StatelessWidget {
//   final String? selectedImageName;
//   final VoidCallback onTap;
//   final String? Function(String?)? validator;
//   final String? titleText;
//   final String? requiredStar;
//   final String? chooseText;
//   final String? imageFile;
//   final Function(FormFieldState<String>)? onImagePicked;
//   const CustomImagePickerWithFormField({
//     Key? key,
//     required this.selectedImageName,
//     required this.onTap,
//     this.validator,
//     this.titleText,
//     this.requiredStar,
//     this.onImagePicked,
//    required this.chooseText,
//     required this.imageFile,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Column(
//       children: [
//         Container(
//           width: screenWidth * 0.90,
//             child: Row(
//               children: [
//                 Text(
//                   '$titleText ',
//                   style: GoogleFonts.openSans(
//                     textStyle: const TextStyle(fontSize: 15),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   requiredStar ?? '',
//                   style: const TextStyle(color: Colors.red, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//         const SizedBox(height: 8),
//         FormField<String>(
//           validator: validator,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           builder: (FormFieldState<String> state) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     onTap();
//                     if (onImagePicked != null) {
//                       onImagePicked!(state);
//                     }
//                   },
//                   child:Container(
//                     height: screenHeight * 0.055,
//                     width: screenWidth * 0.90,
//                     decoration: BoxDecoration(
//                       color: const Color(0xffF2F5F6),
//                       border: Border.all(
//                         color: const Color(0xffF2F5F6),
//                         width: 2,
//                       ),
//                       borderRadius: BorderRadius.circular(5.0),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           width: screenWidth * 0.35,
//                           decoration: BoxDecoration(
//                               color: AppColors.navColor,
//                             borderRadius: BorderRadius.only(topLeft: Radius.circular(5),bottomLeft: Radius.circular(5))
//                           ),
//                           child:  Center(
//                             child: Text(chooseText!,
//                               style: TextStyle(fontSize: 15, color: Colors.white),
//                             ),
//                           ),
//                         ),
//                         Text(
//                           selectedImageName ?? "$imageFile",
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.navColor,
//                           ),
//                         ),
//                         const SizedBox(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 if (state.hasError)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4.0, left: 10),
//                     child: Text(
//                       state.errorText ?? '',
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
import 'dart:io';
import 'package:c9_app/res/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';


class CustomImagePickerWithFormField extends StatelessWidget {
  final String? selectedImageName;
  final VoidCallback onTap;
  final String? Function(String?)? validator;
  final String? titleText;
  final String? requiredStar;
  final String? chooseText;
  final String? imageFile;
  final String? selectedFilePath;
  final Function(FormFieldState<String>)? onImagePicked;

  const CustomImagePickerWithFormField({
    Key? key,
    required this.selectedImageName,
    required this.onTap,
    this.validator,
    this.titleText,
    this.requiredStar,
    this.onImagePicked,
    required this.chooseText,
    required this.imageFile,
    this.selectedFilePath, // Pass file path
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.90,
          child: Row(
            children: [
              Text(
                '$titleText ',
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(fontSize: 15),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                requiredStar ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    onTap();
                    if (onImagePicked != null) {
                      onImagePicked!(state);
                    }
                  },
                  child: Container(
                    height: screenHeight * 0.055,
                    width: screenWidth * 0.90,
                    decoration: BoxDecoration(
                      color: const Color(0xffF2F5F6),
                      border: Border.all(
                        color: const Color(0xffF2F5F6),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: screenWidth * 0.35,
                          decoration: BoxDecoration(
                            color: AppColors.navColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              chooseText!,
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: selectedFilePath != null ?screenWidth * 0.4: screenWidth * 0.5,
                          color: Colors.red,
                          child: Center(
                            child: Text(
                              selectedImageName ?? "$imageFile",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navColor,
                              ),
                            ),
                          ),
                        ),
                        if (selectedFilePath != null)
                          IconButton(
                            icon: Icon(Icons.remove_red_eye, color: AppColors.navColor,),
                            onPressed: () {
                              _previewFile(context);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 10),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        // Text(selectedFilePath??"no path"),
      ],
    );
  }

  void _previewFile(BuildContext context) {
    if (selectedFilePath == null) return;

    // Check if file is an image
    if (selectedFilePath!.endsWith('.jpg') ||
        selectedFilePath!.endsWith('.jpeg') ||
        selectedFilePath!.endsWith('.png')) {
      // Show full-screen image preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imagePath: selectedFilePath!),
        ),
      );
    } else {
      // Open PDF/Word file with external viewer
      OpenFile.open(selectedFilePath!);
    }
  }
}


class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Preview")),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
