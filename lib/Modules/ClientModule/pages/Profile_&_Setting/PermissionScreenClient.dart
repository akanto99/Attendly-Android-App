import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/pages/Profile_&_Setting/AccountDeletion/accountDeletion.dart';
import 'package:c9_app/Modules/ClientModule/pages/Profile_&_Setting/clientChangePassword.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart' as permission_handler;
class PermissonScreenClient extends StatefulWidget {
  final String passEmail;
  const PermissonScreenClient({super.key,required this.passEmail});

  @override
  State<PermissonScreenClient> createState() => _PermissonScreenClientState();
}

class _PermissonScreenClientState extends State<PermissonScreenClient> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ResPonsiveUi(
          mobile: body(context),
          desktop: body(context),
          tablet: body(context),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0,right: 10),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.013,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: HeaderRow(Icons.arrow_back)),
              Text("Account Settings",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
              GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
                  },
                  child: HeaderRow(Icons.home)),
            ],
          ),
          SizedBox(height: screenHeight * 0.013,),

          permissionConTile(
            imageData: AssetImage('images/staff/settingsIcon/acountSettings/mic.png'),
            title: "Mic Permission",
            subtitle: "Status of the Permission",
            permission: permission_handler.Permission.microphone,
            context: context,
          ),

          permissionConTile(
            imageData: AssetImage('images/staff/settingsIcon/acountSettings/file.png'),
            title: "File Permission",
            subtitle: "Status of the Permission",
            permission: permission_handler.Permission.storage,
            context: context,
          ),
          permissionConTile(
            imageData: AssetImage('images/staff/settingsIcon/acountSettings/gallary.png'),
            title: "Image Permission",
            subtitle: "Status of the Permission",
            permission: permission_handler.Permission.storage,
            context: context,
          ),
          permissionConTile(
            imageData: AssetImage('images/staff/settingsIcon/acountSettings/location.png'),
            title: "Location Permission",
            subtitle: "Status of the Permission",
            permission: permission_handler.Permission.location,
            context: context,
          ),

          ChangePasswordContainer(
            imageData: AssetImage('images/staff/settingsIcon/acountSettings/changePass.png'),
            title: "Change Password",
            subtitle: "Create new password",
            context: context,
          ),
          AccountDeleteContainer(
            imageData: AssetImage('images/staff/settingsIcon/acountSettings/acdelete.png'),
            title: "Account Deletion",
            subtitle: "Delete your account",
            context: context,
          )
        ],
      ),
    );
  }

  Widget permissionConTile({
    required AssetImage imageData,
    required String title,
    required String subtitle,
    required permission_handler.Permission permission,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () async {
        final status = await permission.request();
        if (status == permission_handler.PermissionStatus.granted) {
          Utils.flushBarSuccessMessage("Permission Granted", context);
        } else if (status == permission_handler.PermissionStatus.denied) {
          // Permission denied
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Permission denied"),  duration: Duration(seconds: 1),),
          );
        } else if (status == permission_handler.PermissionStatus.permanentlyDenied) {
          // Permission permanently denied
          permission_handler.openAppSettings();
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Color(0xffFFF9DD).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: imageData,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 20),
                    ),
                    Text(subtitle),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios,size: 20,color: Colors.transparent,),
          ],
        ),
      ),
    );
  }

  Widget ChangePasswordContainer({
    required AssetImage imageData,
    required String title,
    required String subtitle,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: (){
        final selectedEmail= '${widget.passEmail}';
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientChangePassword(clientemails:selectedEmail)));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Color(0xffFFF9DD).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: imageData,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 20),
                    ),
                    Text(subtitle),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios,size: 20),
          ],
        ),
      ),
    );
  }


  Widget AccountDeleteContainer({
    required AssetImage imageData,
    required String title,
    required String subtitle,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: (){
        final selectedEmail= '${widget.passEmail}';
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DeleteAccountClient(clientemails:selectedEmail)));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Color(0xffFFF9DD).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: imageData,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 20),
                    ),
                    Text(subtitle),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios,size: 20),
          ],
        ),
      ),
    );
  }}