import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/Widgets/image_with_formField.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class DocumentsStep5 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onStep5;

  DocumentsStep5({
    required this.formKey,
    required this.onStep5,
    Key? key,
  }) : super(key: key);

  @override
  _DocumentsStep5State createState() => _DocumentsStep5State();
}

class _DocumentsStep5State extends State<DocumentsStep5> {
  ///Upload Passport
  Uint8List? _selectedFile1;
  String? _selectedFileName1;
  String? _selectedFilePath;

  ///Proof Of Address
  Uint8List? _selectedProofFile;
  String? _selectedProofFileName;
  String? _selectedProofFilePath;

  ///Proof Of Address
  Uint8List? _selectedLicFile;
  String? _selectedLicFileName;
  String? _selectedLicFilePath;

  ///Upload CPC*
  Uint8List? _selectedCPCFile;
  String? _selectedCPCFileName;
  String? _selectedCPCFilePath;

  ///Upload Tacho*
  Uint8List? _selectedTachoFile;
  String? _selectedTachoFileName;
  String? _selectedTachoFilePath;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedFilePath != null) {
      await prefs.setString('passport_file_path', _selectedFilePath!);
    }
    if (_selectedProofFilePath != null) {
      await prefs.setString('proof_file_path', _selectedProofFilePath!);
    }
    if (_selectedLicFilePath != null) {
      await prefs.setString('upload_driving_licence', _selectedLicFilePath!);
    }
    if (_selectedCPCFilePath != null) {
      await prefs.setString('upload_cpc', _selectedCPCFilePath!);
    }
    if (_selectedTachoFilePath != null) {
      await prefs.setString('upload_tacho', _selectedTachoFilePath!);
    }
  }

  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedFilePath = prefs.getString('passport_file_path');
    String? savedProofFilePath = prefs.getString('proof_file_path');
    String? savedLicFilePath = prefs.getString('upload_driving_licence');
    String? savedCPCFilePath = prefs.getString('upload_cpc');
    String? savedTachoFilePath = prefs.getString('upload_tacho');

    if (savedFilePath != null && File(savedFilePath).existsSync()) {
      String fileName = path.basename(savedFilePath);
      String fileNameShortened = fileName.length > 15
          ? '${fileName.substring(0, 12)}...${path.extension(fileName)}'
          : fileName;

      setState(() {
        _selectedFilePath = savedFilePath;
        _selectedFileName1 = fileNameShortened;
      });
    }

    if (savedProofFilePath != null && File(savedProofFilePath).existsSync()) {
      String proofFileName = path.basename(savedProofFilePath);
      String proofFileNameShortened = proofFileName.length > 15
          ? '${proofFileName.substring(0, 12)}...${path.extension(proofFileName)}'
          : proofFileName;

      setState(() {
        _selectedProofFilePath = savedProofFilePath;
        _selectedProofFileName = proofFileNameShortened;
      });
    }

    if (savedLicFilePath != null && File(savedLicFilePath).existsSync()) {
      String LicFileName = path.basename(savedLicFilePath);
      String LicFileNameShortened = LicFileName.length > 15
          ? '${LicFileName.substring(0, 12)}...${path.extension(LicFileName)}'
          : LicFileName;

      setState(() {
        _selectedLicFilePath = savedLicFilePath;
        _selectedLicFileName = LicFileNameShortened;
      });
    }

    if (savedCPCFilePath != null && File(savedCPCFilePath).existsSync()) {
      String CPCFileName = path.basename(savedCPCFilePath);
      String CPCFileNameShortened = CPCFileName.length > 15
          ? '${CPCFileName.substring(0, 12)}...${path.extension(CPCFileName)}'
          : CPCFileName;

      setState(() {
        _selectedCPCFilePath = savedCPCFilePath;
        _selectedCPCFileName = CPCFileNameShortened;
      });
    }

    if (savedTachoFilePath != null && File(savedTachoFilePath).existsSync()) {
      String TachoFileName = path.basename(savedTachoFilePath);
      String TachoFileNameShortened = TachoFileName.length > 15
          ? '${TachoFileName.substring(0, 12)}...${path.extension(TachoFileName)}'
          : TachoFileName;

      setState(() {
        _selectedTachoFilePath = savedTachoFilePath;
        _selectedTachoFileName = TachoFileNameShortened;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          SizedBox(height: screenHeight * .013,),
          CustomImagePickerWithFormField(
            titleText: "Upload Passport",
            requiredStar: "*",
            chooseText: "Choose doc",
            imageFile: "No doc chosen",
            selectedImageName: _selectedFileName1,
            selectedFilePath: _selectedFilePath,
            onTap: () => _pickFile('passport'),
            validator: (value) {
              if (_selectedFilePath == null) {
                return 'Upload passport is required';
              }
              return null;
            },

          ),
          SizedBox(height: screenHeight * .013,),
          CustomImagePickerWithFormField(
            titleText: "Upload Proof of Address",
            requiredStar: "*",
            chooseText: "Choose doc",
            imageFile: "No doc chosen",
            selectedImageName: _selectedProofFileName,
            selectedFilePath: _selectedProofFilePath,
            onTap: () => _pickFile('proof_of_address'),
            validator: (value) {
              if (_selectedProofFilePath == null) {
                return 'Upload proof of address is required';
              }
              return null;
            },

          ),
          SizedBox(height: screenHeight * .013,),

          CustomImagePickerWithFormField(
            titleText: "Upload Driving Licence",
            requiredStar: "*",
            chooseText: "Choose doc",
            imageFile: "No doc chosen",
            selectedImageName: _selectedLicFileName,
            selectedFilePath: _selectedLicFilePath,
            onTap: () => _pickFile('upload_driving_licence'),
            validator: (value) {
              if (_selectedLicFilePath == null) {
                return 'Upload driving licence is required';
              }
              return null;
            },

          ),
          SizedBox(height: screenHeight * .013,),

          CustomImagePickerWithFormField(
            titleText: "Upload CPC",
            requiredStar: "*",
            chooseText: "Choose doc",
            imageFile: "No doc chosen",
            selectedImageName: _selectedCPCFileName,
            selectedFilePath: _selectedCPCFilePath,
            onTap: () => _pickFile('upload_cpc'),
            validator: (value) {
              if (_selectedCPCFilePath == null) {
                return 'Upload CPC is required';
              }
              return null;
            },

          ),
          SizedBox(height: screenHeight * .013,),

          CustomImagePickerWithFormField(
            titleText: "Upload Tacho",
            requiredStar: "*",
            chooseText: "Choose doc",
            imageFile: "No doc chosen",
            selectedImageName: _selectedTachoFileName,
            selectedFilePath: _selectedTachoFilePath,
            onTap: () => _pickFile('upload_tacho'),
            validator: (value) {
              if (_selectedTachoFilePath == null) {
                return 'Upload Tacho licence is required';
              }
              return null;
            },

          ),
          SizedBox(height: screenHeight * .013,),

          GestureDetector(
            onTap: ()async{
              _saveFormData();
              if (widget.formKey.currentState?.validate() ?? false ) {
                widget.onStep5();
              }
            },
            child: Container(
              height: screenHeight * 0.05,
              width: screenWidth * 0.7,
              decoration: BoxDecoration(
                color: Color(0xff2664EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AutoSizeText(
                  "CONTINUE",
                  maxLines: 1,
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(fontSize: 16),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * .1,),
        ],
      ),
    );
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.single;
        String fileName = file.name;
        Uint8List? fileData = file.bytes;
        String? filePath = file.path;

        if (fileData == null && filePath != null) {
          File fileOnDisk = File(filePath);
          fileData = await fileOnDisk.readAsBytes();
        }

        String fileNameShortened = fileName.length > 15
            ? '${fileName.substring(0, 12)}...${path.extension(fileName)}'
            : fileName;

        setState(() {
          if (type == 'passport') {
            _selectedFile1 = fileData;
            _selectedFileName1 = fileNameShortened;
            _selectedFilePath = filePath;
          } else if (type == 'proof_of_address') {
            _selectedProofFile = fileData;
            _selectedProofFileName = fileNameShortened;
            _selectedProofFilePath = filePath;
          } else if (type == 'upload_driving_licence') {
            _selectedLicFile = fileData;
            _selectedLicFileName = fileNameShortened;
            _selectedLicFilePath = filePath;
          }
          else if (type == 'upload_cpc') {
            _selectedCPCFile = fileData;
            _selectedCPCFileName = fileNameShortened;
            _selectedCPCFilePath = filePath;
          }
          else if (type == 'upload_tacho') {
            _selectedTachoFile = fileData;
            _selectedTachoFileName = fileNameShortened;
            _selectedTachoFilePath = filePath;
          }
        });

        // Manually update the form field state
        widget.formKey.currentState?.validate();
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }
}
