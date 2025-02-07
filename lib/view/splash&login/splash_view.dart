import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view_model/services/splash_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';


class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  SplashServices splashServices = SplashServices();

  @override
  void initState() {
    super.initState();
    splashServices.checkAuthentication(context);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height *1;
    final screenWidth = MediaQuery.of(context).size.width *1;

    return SingleChildScrollView(
      child: Column(
      
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
      
      
      
          SizedBox(),
      
      
          Center(
            child: Column(
              children: [
                Container(
                    height: screenHeight*0.9,
                    width: screenWidth*0.5,
                  // color: Colors.red,
                  child:  Image.asset("images/c9LogoLatest.png",),
                  // child:  Image.asset("images/splashimg.png",),
                  ),
      
      
                Text("Attendly",style: (TextStyle(color:AppColors.navButtonColor,fontSize: 25,fontWeight: FontWeight.w500)),),
      
              ],
            ),
      
      
          ),
      
          // Text("Attendly",style: (TextStyle(color:Color(0xffffa801),fontSize: 15,fontWeight: FontWeight.w500)),),
      
        ],
      ),
    );}
}
