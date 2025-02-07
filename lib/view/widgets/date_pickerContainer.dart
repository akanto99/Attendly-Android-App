import 'package:c9_app/res/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateContainer extends StatelessWidget {
  final String Textlabel;
  final String labelText;
  final String ?requiredStar;
  final TextEditingController controller;
  final String? errorMessage;

  const DateContainer({
    Key? key,
    required this.Textlabel,
    required this.labelText,
     this.requiredStar,
    required this.controller,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.95,
          child: Row(
            children: [
              Text(Textlabel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(requiredStar??"",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              )
            ],
          ),
        ),
        Container(
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.2),
            border: Border.all(
              color: AppColors.navButtonColor.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.datetime,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              hintText: labelText,
              hintStyle: TextStyle(
                color: AppColors.blackColor.withOpacity(0.5),
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.black,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime(2101),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        onPrimary: Colors.white,
                        onBackground: Colors.white,
                        onSurface: Colors.black,
                        primary: AppColors.navColor,
                        brightness: Brightness.light,
                        surface: Colors.white,
                      ),
                      datePickerTheme: const DatePickerThemeData(
                        headerBackgroundColor: AppColors.navColor,
                        backgroundColor: Colors.white,
                        headerForegroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.navButtonColor,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                String formattedDate =
                DateFormat('dd-MM-yyyy').format(pickedDate);
                controller.text = formattedDate;
              }
            },
          ),
        ),
        if (errorMessage != null && errorMessage!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                errorMessage!,
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
  }
}
