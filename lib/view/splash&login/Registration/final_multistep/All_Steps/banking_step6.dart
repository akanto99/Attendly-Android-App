import 'package:flutter/material.dart';

class BankingStep6 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onStep6;
  const BankingStep6({required this.formKey,
    required this.onStep6,
    super.key});

  @override
  State<BankingStep6> createState() => _BankingStep6State();
}

class _BankingStep6State extends State<BankingStep6> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:    ElevatedButton(onPressed: ()async{
          widget.onStep6();
        }, child: Text("Continue")),
      ),
    );
  }
}
