import 'dart:io';
import 'dart:developer';
import '../../alert.dart';
import '../../DisplayPicture.dart';
import 'package:flutter/material.dart';
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
      if (capturedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No file  was  selected"),
            backgroundColor: Colors.red,
          ),
        );
        //  showAlert(
        //     bContext: context,
        //     title: "Error choosing file",
        //     content: "No file was selected",
        //   );
      } else {
        final File imagePath = File(capturedImage.path);
        log("Image Path: ${imagePath.path}");
        String fileName = imagePath.path.split('/').last;
        log("File Name: $fileName");
        String targetPath = '$appDocPath/$fileName';
        log("Target Path: $targetPath");

        // final File newImage = await imagePath.copy('$appDocPath/$fileName');
        var result = await FlutterImageCompress.compressAndGetFile(
          imagePath.absolute.path,
          targetPath,
          minWidth: 2300,
          minHeight: 1500,
          quality: 50,
        );

        // setState(() {
        //   _image = imagePath;
        // });
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         DisplayPicture(image: _image, context: context),
        //   ),
        // );
      }
    } catch (e) {
      showAlert(
        bContext: context,
        title: "Error capturing image file",
        content: e.toString(),
      );
    }
  }

  _imageFromGallery() async {
    XFile? uploadedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (uploadedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No image to upload"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final File imagePath = File(uploadedImage.path);
      setState(() {
        _image = imagePath;
      });
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => DisplayPicture(image: _image, context: context),
      //   ),
      // );
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          216,
                          213,
                          213,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 60),

                          SizedBox(height: 10),
                          Text(
                            "Take Picture",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        await _imageFromCamera();
                        setState(() {}); // Update UI after selecting the file
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          216,
                          213,
                          213,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.browse_gallery_sharp, size: 60),
                          SizedBox(height: 10),
                          Text(
                            "From Gallery",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () => {_imageFromGallery()},
                    ),
                  ),
                ],
              ),

              //upload picture
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 216, 213, 213),
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Icon(Icons.photo_library_outlined, size: 60),
                    ),
                    Text(
                      "Upload Picture",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PatientInfo()),
                  ),
                },
              ),
              //documents uplodaed to view here
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 216, 213, 213),
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Icon(Icons.edit_document, size: 50),
                    ),
                    Text(
                      "     View \nDocuments",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Viewdocuments()),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
