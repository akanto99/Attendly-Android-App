// image_picker_widget.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:c9_app/res/color.dart'; // Ensure this import is correct for your project structure

class ImagePickerWidget extends StatefulWidget {
  final String title;
  final double screenWidth;
  final double screenHeight;
  final Function(Uint8List?, String?) onImagePicked;
  final String? selectedImageName;
  final String? errorMessage;

  ImagePickerWidget({
    required this.title,
    required this.screenWidth,
    required this.screenHeight,
    required this.onImagePicked,
    this.selectedImageName,
    this.errorMessage,
  });

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    XFile? pickedImage = await _imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      Uint8List imageData = await pickedImage.readAsBytes();
      String imageName = pickedImage.name;
      List<String> fileNameParts = imageName.split('.');
      String imageExtension = fileNameParts.last;
      String imageNameShortened = imageName.length > 15
          ? imageName.substring(0, 15) + "..." + imageExtension
          : imageName;

      widget.onImagePicked(imageData, imageNameShortened);
    } else {
      print('No image selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _pickImage(ImageSource.gallery);
          },
          child: Container(
            height: widget.screenHeight * 0.065,
            width: widget.screenWidth * 0.90,
            decoration: BoxDecoration(
              color: AppColors.navOpacity.withOpacity(0.2),
              border: Border.all(
                color: AppColors.navButtonColor.withOpacity(0.4),
                width: 0.4,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: widget.screenHeight * 0.065,
                  width: widget.screenWidth * 0.30,
                  decoration: BoxDecoration(
                    color: AppColors.navOpacity,
                    border: Border.all(
                      color: AppColors.navOpacity,
                      width: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      "Choose image",
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ),
                Text(
                  widget.selectedImageName ?? "No image chosen",
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                SizedBox(),
              ],
            ),
          ),
        ),
        if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) // Render error message only if not empty
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
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
