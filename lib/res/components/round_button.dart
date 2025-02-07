import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/res/color.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {

  final String title ;
  final bool loading ;
  final VoidCallback onPress ;
  const RoundButton({Key? key ,
    required this.title,
    this.loading = false ,
     required this.onPress ,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return InkWell(
      onTap: onPress,
      child: Container(
        height: screenHeight*0.05,
        width: screenWidth*0.45,
        decoration: BoxDecoration(
          color:AppColors.navButtonColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Center(
            child:loading ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white,)) :  AutoSizeText(title ,
              style: TextStyle(color: AppColors.whiteColor,fontSize: 23,letterSpacing: 1),
            )),
      ),
    );
  }
}
class RoundButtonLogo extends StatelessWidget {

  final String title ;
  final bool loading ;
  final VoidCallback onPress ;
  const RoundButtonLogo({Key? key ,
    required this.title,
    this.loading = false ,
    required this.onPress ,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Container(
      width: screenWidth*0.95,
      // color: Colors.blueAccent,
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: onPress,
          child: Container(
            height: screenHeight*0.06,
            width: screenWidth*0.5,
            decoration: BoxDecoration(
                color:AppColors.navColor,
                // color:Color(0xffFF9541),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                    child:loading ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white,)) :  AutoSizeText(title ,
                      style: TextStyle(color: AppColors.whiteColor,fontSize: 19,letterSpacing: 1,fontWeight: FontWeight.w500),
                    )),
                Icon(Icons.arrow_right_alt,color: Colors.white,size: 25,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
