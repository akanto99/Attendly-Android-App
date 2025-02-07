
import 'package:flutter/material.dart';


class ConfirmationStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  ConfirmationStep({Key? key, required this.formKey}) : super(key: key);

  @override
  State<ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends State<ConfirmationStep> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Center(
        child: Text('Confirmation UI goes here'),
      ),
    );
  }
}