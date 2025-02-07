import 'package:c9_app/res/color.dart';
import 'package:flutter/material.dart';


class ContactDetailsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController niNumberController;
  String? niNumberValidationError;

  ContactDetailsStep({
    required this.formKey,
    required this.niNumberController,
    this.niNumberValidationError,
    Key? key,
  }) : super(key: key);

  @override
  State<ContactDetailsStep> createState() => _ContactDetailsStepState();
}

class _ContactDetailsStepState extends State<ContactDetailsStep> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          _buildCustomContainer(
            titleText: 'Ni Number',
            placeholder: 'Enter your address line 1',
            controller: widget.niNumberController,
            errorMessage: widget.niNumberValidationError,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  widget.niNumberValidationError = 'First name is required and must be at least 3 characters long.';
                } else if (value.length < 3) {
                  widget.niNumberValidationError = 'First name must be at least 3 characters long.';
                } else {
                  widget.niNumberValidationError = null;
                }
              });
            },
          ),
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