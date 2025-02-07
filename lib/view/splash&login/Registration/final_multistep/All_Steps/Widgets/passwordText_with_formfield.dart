import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final ValueNotifier<bool> obscurePasswordNotifier;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String?)? onChanged;

  const PasswordField({
    required this.controller,
    required this.label,
    required this.obscurePasswordNotifier,
    required this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
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
              Text(widget.label,
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(fontSize: 15),
                    fontWeight: FontWeight.bold,
                  )),
              Text(
                " *",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> field) {
            return ValueListenableBuilder(
              valueListenable: widget.obscurePasswordNotifier,
              builder: (context, value, child) {
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
                        obscureText: widget.obscurePasswordNotifier.value,
                        obscuringCharacter: "*",
                        keyboardType: widget.keyboardType,
                        decoration: InputDecoration(
                          hintText: widget.label,
                          hintStyle: GoogleFonts.openSans(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                          errorMaxLines: 3,
                          errorStyle: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
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
                          suffixIcon: InkWell(
                            onTap: () {
                              widget.obscurePasswordNotifier.value = !widget.obscurePasswordNotifier.value;
                            },
                            child: Icon(
                              widget.obscurePasswordNotifier.value ? Icons.visibility_off_outlined : Icons.visibility,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          widget.onChanged?.call(value);
                          field.didChange(value); // This is where didChange is called correctly
                        },
                      ),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          field.errorText ?? '',
                          style: TextStyle(fontSize: 12, color: field.errorText == 'Passwords match' ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
