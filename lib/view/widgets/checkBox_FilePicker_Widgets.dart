import 'dart:io';
import 'dart:typed_data';

import 'package:c9_app/res/color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class CheckFilePickerWidget extends StatefulWidget {
  final String title;
  final double screenWidth;
  final double screenHeight;
  final Function(Uint8List?, String?) onFilePicked;
  final String? checkselectedFileName;
  final Function(bool?) onCheckboxChanged;
  final String? errorMessage;

  CheckFilePickerWidget({
    required this.title,
    required this.screenWidth,
    required this.screenHeight,
    required this.onFilePicked,
    required this.onCheckboxChanged,
    this.checkselectedFileName,
    this.errorMessage,
  });

  @override
  _CheckFilePickerWidgetState createState() => _CheckFilePickerWidgetState();
}

class _CheckFilePickerWidgetState extends State<CheckFilePickerWidget> {
  bool _isCheckboxChecked = false;

  // Future<void> _pickFile() async {
  //   if (_isCheckboxChecked) return;
  //
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
  //     );
  //
  //     if (result != null && result.files.isNotEmpty) {
  //       PlatformFile file = result.files.single;
  //
  //       String fileName = file.name;
  //       Uint8List fileData = file.bytes ?? Uint8List(0); // Ensure fileData is not null
  //
  //       print('Selected file name: $fileName'); // Debug print
  //
  //       String fileNameShortened = fileName.isNotEmpty && fileName.length > 15
  //           ? '${fileName.substring(0, 15)}...${fileName.substring(fileName.lastIndexOf('.') + 1)}'
  //           : fileName;
  //
  //       widget.onFilePicked(fileData, fileNameShortened);
  //     } else {
  //       print('No file selected');
  //     }
  //   } catch (e) {
  //     print('Error picking file: $e');
  //   }
  // }

  Future<void> _pickFile() async {
    if (_isCheckboxChecked) return;

    try {
      print('Attempting to pick a file');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.single;
        String fileName = file.name;
        Uint8List? fileData = file.bytes;

        print('Selected file name: $fileName');
        print('Selected file size: ${file.size}');
        print('Selected file bytes: $fileData');

        if (fileData == null && file.path != null) {
          File fileOnDisk = File(file.path!);
          fileData = await fileOnDisk.readAsBytes();
          print('Read file bytes from path: $fileData');
        }

        String fileNameShortened = fileName.isNotEmpty && fileName.length > 15
            ? '${fileName.substring(0, 15)}...${path.extension(fileName)}'
            : fileName;

        widget.onFilePicked(fileData, fileNameShortened);
      } else {
        print('No file selected');
        widget.onFilePicked(null, null);
      }
    }  catch (e) {
      print('Error picking file: $e');
    }
  }


  void _handleCheckboxChanged(bool? value) {
    setState(() {
      _isCheckboxChecked = value ?? false;
    });
    widget.onCheckboxChanged(value);
  }





  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left :10,),
          child: Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),

                    Text(
                      ' *',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),

                  ],
                ),
              ),
              // Spacer(),
              // Checkbox(
              //   value: _isCheckboxChecked,
              //   onChanged: _handleCheckboxChanged,
              // ),
              // Text("I don't have one")
            ],
          ),
        ),
        SizedBox(height: screenHeight * .013),

        GestureDetector(
          onTap: _pickFile,
          child: Container(
            height: screenHeight * 0.063,
            width: screenWidth * 0.90,
            decoration: BoxDecoration(
              color: _isCheckboxChecked ?Colors.grey[300]! : AppColors.navOpacity.withOpacity(0.2),
              border: Border.all(
                color: _isCheckboxChecked ? AppColors.navButtonColor.withOpacity(0.4) : AppColors.navButtonColor.withOpacity(0.4),
                width: 0.4,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Row(
              children: [
                Container(
                  height: screenHeight * 0.063,
                  width: screenWidth * 0.30,
                  decoration: BoxDecoration(
                    color: _isCheckboxChecked ? Colors.grey[300]! : AppColors.navOpacity,
                    border: Border.all(
                      color: _isCheckboxChecked ? Colors.grey[300]! : AppColors.navOpacity,
                      width: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(
                    child: Text(
                      "Choose file",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.checkselectedFileName ?? "No file chosen",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

        ),
        // if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) // Render error message only if not empty
        //   Padding(
        //     padding: const EdgeInsets.only(left: 10.0),
        //     child: Align(
        //       alignment: Alignment.topLeft,
        //       child: Text(
        //         widget.errorMessage!,
        //         style: TextStyle(
        //           fontSize: 12,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.red,
        //         ),
        //       ),
        //     ),
        //   ),
        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty && !_isCheckboxChecked) // Render error message only if not empty and passport checkbox is not checked
          Padding(
            padding: const EdgeInsets.only(left :10,),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                widget.errorMessage!,
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

