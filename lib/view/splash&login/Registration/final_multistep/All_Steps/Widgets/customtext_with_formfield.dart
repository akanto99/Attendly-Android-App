import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFieldWithFormField extends StatefulWidget {
  final String titleText;
  final String? requiredStar;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode? focusCurrent;
  final FocusNode? focusNext;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final VoidCallback? onEditingComplete;

  CustomTextFieldWithFormField({
    Key? key,
    required this.titleText,
    this.requiredStar,
    required this.placeholder,
    required this.controller,
    this.focusCurrent,
    this.focusNext,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
  }) : super(key: key);

  @override
  State<CustomTextFieldWithFormField> createState() => _CustomTextFieldWithFormFieldState();
}

class _CustomTextFieldWithFormFieldState extends State<CustomTextFieldWithFormField> {
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
                '${widget.titleText} ',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(fontSize: 15),
                    fontWeight: FontWeight.bold,
                  )
              ),
              Text(
                "${widget.requiredStar ?? ''}",
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> fieldState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screenHeight * 0.055,
                  width: screenWidth * 0.90,
                  decoration: BoxDecoration(
                    color: Color(0xffF2F5F6),
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: Color(0xffEAECED),
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: widget.focusCurrent,
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: widget.placeholder,
                      hintStyle: GoogleFonts.openSans(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.8,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 0.4,
                        ),
                      ),
                    ),
                    onFieldSubmitted: widget.onFieldSubmitted,
                    onChanged: (value) {
                      fieldState.didChange(value);
                      if (widget.onChanged != null) {
                        widget.onChanged!(value);
                      }
                    },
                  ),
                ),
                if (fieldState.hasError)
                  Container(
                    width: screenWidth * 0.90,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                      child: Text(
                        fieldState.errorText ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
