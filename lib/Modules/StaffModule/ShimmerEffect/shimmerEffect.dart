import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({super.key});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> {
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
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final curvedNavigationBarHeight = 45.0;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
          width: screenWidth,
          height: screenHeight-curvedNavigationBarHeight,
          child: Column(
            children: [
              SizedBox(height: screenHeight*0.013,),
              Container(
                height: screenHeight*0.07,
                width: screenWidth*0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),),
              ),
              SizedBox(height: screenHeight*0.013,),

              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(10),
                  separatorBuilder: (_,__)=> SizedBox(height: 16,),
                  itemCount: 10,
                  itemBuilder: (context,index){
                    return SizedBox(height: 96,
                      child: Row(
                        children: [
                          Container(
                            height: 96,
                            width: 96,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: 20,
                                  // width: 96,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  // width: 96,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(child: Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                    ),
                                    ),
                                    SizedBox(width: 10,),
                                    Expanded(
                                      child: Container(
                                        height: 20,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8)
                                        ),
                                      ),),

                                  ],
                                )
                              ],
                            ),
                          ),


                        ],
                      ),);
                  },
                ),
              ),
            ],
          )
      ),
    );
  }
}
