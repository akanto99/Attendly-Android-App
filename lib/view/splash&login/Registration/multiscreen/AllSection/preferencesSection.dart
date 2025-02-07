import 'package:flutter/material.dart';


class PreferencesStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  PreferencesStep({Key? key, required this.formKey}) : super(key: key);

  @override
  State<PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends State<PreferencesStep> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Center(
        child: Text('Preferences Selection UI goes here'),
      ),
    );
  }
}