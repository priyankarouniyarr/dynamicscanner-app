import 'dart:io';
import 'dart:developer';
import '../../alert.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter.blur
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dynamicemrapp/screen/document%20scanner/viewDocuments.dart';
import 'package:dynamicemrapp/screen/document%20scanner/patientInformation.dart';

class AddImage extends StatefulWidget {
  AddImage({Key? key}) : super(key: key);
  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  late File _image;
  ImagePicker imagePicker = ImagePicker();
  String tempPath = "";
  String appDocPath = "";

  // Track interaction state for each card
  bool _isCameraCardInteracted = false;
  bool _isGalleryCardInteracted = false;
  bool _isUploadCardInteracted = false;
  bool _isViewCardInteracted = false;

  _imageFromCamera() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      tempPath = tempDir.path;
      log("Temporary Directory Path: $tempPath");

      Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory appDocDirFolder = Directory(
        '${appDocDir.path}/DynamicEmrScan/',
      );
      final Directory appScanFolder = await appDocDirFolder.create(
        recursive: true,
      );
      appDocPath = appScanFolder.path;
      log("Application Document Directory Path: $appDocPath");

      XFile? capturedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
      );
      log("Captured Image Path: ${capturedImage?.path}");
      if (!mounted) return;
      if (capturedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No file was selected"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        final File imagePath = File(capturedImage.path);
        log("Image Path: ${imagePath.path}");
        String fileName = imagePath.path.split('/').last;
        log("File Name: $fileName");
        String targetPath = '$appDocPath/$fileName';
        log("Target Path: $targetPath");

        var result = await FlutterImageCompress.compressAndGetFile(
          imagePath.absolute.path,
          targetPath,
          minWidth: 2300,
          minHeight: 1500,
          quality: 50,
        );

        if (result != null && mounted) {
          setState(() {
            _image = File(result.path);
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to compress image"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      log("Error in _imageFromCamera: $e\n$stackTrace");
      if (mounted) {
        showAlert(
          bContext: context,
          title: "Error capturing image file",
          content: e.toString(),
        );
      }
    }
  }

  _imageFromGallery() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      tempPath = tempDir.path;
      log("Temporary Directory Path: $tempPath");

      Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory appDocDirFolder = Directory(
        '${appDocDir.path}/DynamicEmrScan/',
      );
      final Directory appScanFolder = await appDocDirFolder.create(
        recursive: true,
      );
      appDocPath = appScanFolder.path;
      log("Application Document Directory Path: $appDocPath");

      XFile? uploadedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (!mounted) return;
      if (uploadedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No image to upload"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final File imagePath = File(uploadedImage.path);
      log("Image Path: ${imagePath.path}");
      String fileName = imagePath.path.split('/').last;
      log("File Name: $fileName");
      String targetPath = '$appDocPath/$fileName';
      log("Target Path: $targetPath");

      var result = await FlutterImageCompress.compressAndGetFile(
        imagePath.absolute.path,
        targetPath,
        minWidth: 2300,
        minHeight: 1500,
        quality: 50,
      );

      if (result != null && mounted) {
        setState(() {
          _image = File(result.path);
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to compress image"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      log("Error in _imageFromGallery: $e\n$stackTrace");
      if (mounted) {
        showAlert(
          bContext: context,
          title: "Error selecting image file",
          content: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(46, 25, 96, 1),
            Color.fromRGBO(93, 16, 73, 1),
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: BackButton(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGlassCard(
                    icon: Icons.camera_alt_outlined,
                    label: "Take Picture",
                    isInteracted: _isCameraCardInteracted,
                    onTap: () async {
                      await _imageFromCamera();
                      if (mounted) setState(() {});
                    },
                    onTapDown: () =>
                        setState(() => _isCameraCardInteracted = true),
                    onTapUp: () =>
                        setState(() => _isCameraCardInteracted = false),
                    onTapCancel: () =>
                        setState(() => _isCameraCardInteracted = false),
                    onHover: (isHovered) =>
                        setState(() => _isCameraCardInteracted = isHovered),
                  ),
                  _buildGlassCard(
                    icon: Icons.browse_gallery_sharp,
                    label: "Pick From Gallery",
                    isInteracted: _isGalleryCardInteracted,
                    onTap: () async {
                      await _imageFromGallery();
                      if (mounted) setState(() {});
                    },
                    onTapDown: () =>
                        setState(() => _isGalleryCardInteracted = true),
                    onTapUp: () =>
                        setState(() => _isGalleryCardInteracted = false),
                    onTapCancel: () =>
                        setState(() => _isGalleryCardInteracted = false),
                    onHover: (isHovered) =>
                        setState(() => _isGalleryCardInteracted = isHovered),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGlassCard(
                    icon: Icons.photo_library_outlined,
                    label: "Upload Picture",
                    isInteracted: _isUploadCardInteracted,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PatientInfo()),
                      );
                    },
                    onTapDown: () =>
                        setState(() => _isUploadCardInteracted = true),
                    onTapUp: () =>
                        setState(() => _isUploadCardInteracted = false),
                    onTapCancel: () =>
                        setState(() => _isUploadCardInteracted = false),
                    onHover: (isHovered) =>
                        setState(() => _isUploadCardInteracted = isHovered),
                  ),
                  _buildGlassCard(
                    icon: Icons.document_scanner_outlined,
                    label: "View Documents",
                    isInteracted: _isViewCardInteracted,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Viewdocuments(),
                        ),
                      );
                    },
                    onTapDown: () =>
                        setState(() => _isViewCardInteracted = true),
                    onTapUp: () =>
                        setState(() => _isViewCardInteracted = false),
                    onTapCancel: () =>
                        setState(() => _isViewCardInteracted = false),
                    onHover: (isHovered) =>
                        setState(() => _isViewCardInteracted = isHovered),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required String label,
    required bool isInteracted,
    required VoidCallback onTap,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
    required Function(bool) onHover,
  }) {
    return InkWell(
      onTap: onTap,
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapCancel,
      onHover: onHover,
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.blue.withOpacity(0.3),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 50),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isInteracted ? 1.15 : 1.0),
        transformAlignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isInteracted ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isInteracted ? 0.3 : 0.1),
                    blurRadius: isInteracted ? 15 : 10,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(icon, size: 40, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
