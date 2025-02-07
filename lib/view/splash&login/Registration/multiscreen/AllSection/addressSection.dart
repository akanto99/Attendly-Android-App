import 'package:c9_app/res/color.dart';
import 'package:flutter/material.dart';
class AddressStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController ? addressController;
  String? addressLine1ValidationError;

  AddressStep({
    required this.formKey,
     this.addressController,
    this.addressLine1ValidationError,
    Key? key,
  }) : super(key: key);

  @override
  State<AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<AddressStep> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // Center(
          //   child: TextFormField(
          //     controller: controller,
          //     decoration: InputDecoration(
          //       labelText: 'Address',
          //       hintText: 'Enter your address',
          //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          //     ),
          //     // validator: (value) {
          //     //   if (value == null || value.isEmpty) {
          //     //     return 'Address is required';
          //     //   }
          //     //   return null;
          //     // },
          //   ),
          // ),

          // _buildCustomContainer(
          //   titleText: 'Address Line 1',
          //   placeholder: 'Enter your address line 1',
          //   controller: widget.addressController ,
          //   errorMessage: widget.addressLine1ValidationError,
          //   onChanged: (value) {
          //     setState(() {
          //       if (value.isEmpty) {
          //         widget.addressLine1ValidationError =
          //         'First name is required and must be at least 3 characters long.';
          //       } else if (value.length < 3) {
          //         widget.addressLine1ValidationError = 'First name must be at least 3 characters long.';
          //       } else {
          //         widget.addressLine1ValidationError = null;
          //       }
          //     });
          //   },
          // ),
        ],
      ),
    );
  }

  _buildCustomContainer({
    required String titleText,
    required String placeholder,
    required TextEditingController controller,
    String? errorMessage,
    required Function(String) onChanged,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$titleText ',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              '*',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: AppColors.navButtonColor.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
        // Show error message only if there is an error
        if (errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 4.0),
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}