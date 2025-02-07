import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomValidateFormField extends StatelessWidget {
  final String titleText;
  final String? requiredStar;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;

  const CustomValidateFormField({
    Key? key,
    required this.titleText,
    this.requiredStar,
    required this.controller,
    required this.hintText,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FormField<String>(
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: controller.text,
      builder: (FormFieldState<String> state) {
        return Column(
          children: [
       Container(
              width: screenWidth * 0.90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      titleText,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(fontSize: 15),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text("${requiredStar ?? ''}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ),


            SizedBox(height: screenHeight * 0.013),
            Container(
              height: screenHeight * 0.15,
              width: screenWidth * 0.90,
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              decoration: BoxDecoration(
                color: Color(0xffF2F5F6),
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Color(0xffEAECED),
                  width: 1,
                ),
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  prefixIcon: const Icon(
                    Icons.edit,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: const TextStyle(fontSize: 14),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  // Trigger re-validation when text changes
                  state.didChange(value);
                },
              ),
            ),
            if (state.hasError)
              Container(
                width: screenWidth * 0.90,
                child:  Padding(
                  padding: const EdgeInsets.only(top: 4.0,left: 10),
                  child: Text(
                    state.errorText ?? '',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
