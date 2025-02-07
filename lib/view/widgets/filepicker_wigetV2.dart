import 'dart:io';
import 'dart:typed_data';

import 'package:c9_app/res/color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FilePickerWidgetV2 extends StatefulWidget {
  final String title;
  final double screenWidth;
  final double screenHeight;
  final Function(Uint8List?, String?) onFilePicked;
  final String? selectedFileName;
  final String? errorMessage;


  FilePickerWidgetV2 ({
    required this.title,
    required this.screenWidth,
    required this.screenHeight,
    required this.onFilePicked,
    this.selectedFileName,
    this.errorMessage,
  });

  @override
  _FilePickerWidgetV2State createState() => _FilePickerWidgetV2State();
}

class _FilePickerWidgetV2State extends State<FilePickerWidgetV2> {

  Future<void> _pickFile() async {
    try {
      print('Attempting to pick a file');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf',],
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
    } catch (e) {
      print('Error picking file: $e');
      widget.onFilePicked(null, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Flexible(
          flex: 2,
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Align(
           alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: widget.screenHeight * 0.055,
                width: widget.screenWidth * 0.4,
                decoration: BoxDecoration(
                  color: Color(0xffF2F5F6),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Color(0xffEAECED),
                    width: 1,
                  ),),
                child: Center(
                  child: Text(
                    widget.selectedFileName ?? "Choose file",
                    style: TextStyle(fontSize: 12, color: Colors.blue,fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) // Render error message only if not empty
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
