import 'package:c9_app/res/color.dart';
import 'package:flutter/material.dart';

/// NO INTERNET CONNECTION


class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_sharp, size: 50, color: AppColors.navColor),
          SizedBox(height: 8),
          Text("Can't connect",
              style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 5),
              Text('Please check your internet connection',
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
