import 'package:c9_app/res/color.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class CustomTextField extends StatelessWidget {
  final String titleText;
  final String? requiredStar;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode? focusCurrent;
  final FocusNode? focusNext;
   String? errorMessage;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final VoidCallback? onEditingComplete;


   CustomTextField({
    Key? key,
    required this.titleText,
    this.requiredStar,
    required this.placeholder,
    required this.controller,
    this.focusCurrent,
    this.focusNext,
    this.errorMessage,
    this.onChanged,
    this.validator,
    this.onEditingComplete,
    this.onFieldSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenWidth * 0.95,
          child: Row(
            children: [
              Text(
                '$titleText ',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                "${requiredStar ?? ''}",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: screenWidth * 0.95,
          // decoration: BoxDecoration(
          //   color: AppColors.navOpacity.withOpacity(0.2),
          //   borderRadius: BorderRadius.circular(8.0),
          // ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              focusNode: focusCurrent,
              decoration: InputDecoration(
                errorMaxLines: 3,
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold
                ),
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 0.4,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 14.0,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 0.4,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 0.4,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.green,
                    width: 0.4,
                  ),
                ),
              ),
              onFieldSubmitted: onFieldSubmitted,
              // onFieldSubmitted: (value) {
              //   if (focusCurrent != null && focusNext != null) {
              //     Utils.fieldFocusChange(context, focusCurrent!, focusNext!);
              //   }
              // },
              onChanged: onChanged,
              validator: validator,
              onEditingComplete: onEditingComplete,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ),
        // if (errorMessage != null && errorMessage!.isNotEmpty) // Render error message only if not empty
        //   Padding(
        //     padding: const EdgeInsets.only(left: 10.0),
        //     child: Align(
        //       alignment: Alignment.topLeft,
        //       child: Text(
        //         errorMessage!,
        //         style: TextStyle(
        //           fontSize: 12,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.red,
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
