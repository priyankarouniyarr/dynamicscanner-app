import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dynamicemrapp/screen/document%20scanner/patientInformation.dart';

class DisplayPicture extends StatefulWidget {
  final List<File> images;
  final BuildContext context;

  DisplayPicture({Key? key, required this.images, required this.context})
    : super(key: key);

  @override
  _DisplayPictureState createState() => _DisplayPictureState();
}

class _DisplayPictureState extends State<DisplayPicture> {
  final ImagePicker _imagePicker = ImagePicker();
  String _appDocPath = "";
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializePaths();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializePaths() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory appDocDirFolder = Directory(
      '${appDocDir.path}/DynamicEmrScan/',
    );
    final Directory appScanFolder = await appDocDirFolder.create(
      recursive: true,
    );
    setState(() {
      _appDocPath = appScanFolder.path;
    });
  }

  Future<void> _addImageFromCamera() async {
    try {
      XFile? capturedImage = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
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
        String fileName = imagePath.path.split('/').last;
        String targetPath = '$_appDocPath/$fileName';

        var result = await FlutterImageCompress.compressAndGetFile(
          imagePath.absolute.path,
          targetPath,
          minWidth: 2300,
          minHeight: 1500,
          quality: 50,
        );

        if (result != null && mounted) {
          setState(() {
            widget.images.add(File(result.path));
            _currentPage = widget.images.length - 1;
            _pageController.jumpToPage(_currentPage);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Image captured successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to compress image"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error capturing image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addImageFromGallery() async {
    try {
      XFile? uploadedImage = await _imagePicker.pickImage(
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
      } else {
        final File imagePath = File(uploadedImage.path);
        String fileName = imagePath.path.split('/').last;
        String targetPath = '$_appDocPath/$fileName';

        var result = await FlutterImageCompress.compressAndGetFile(
          imagePath.absolute.path,
          targetPath,
          minWidth: 2300,
          minHeight: 1500,
          quality: 50,
        );

        if (result != null && mounted) {
          setState(() {
            widget.images.add(File(result.path));
            _currentPage = widget.images.length - 1;
            _pageController.jumpToPage(_currentPage);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Image selected successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to compress image"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error selecting image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteImage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Image"),
        content: Text("Are you sure you want to delete this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.images.removeAt(index);
                if (_currentPage >= widget.images.length && _currentPage > 0) {
                  _currentPage--;
                  _pageController.jumpToPage(_currentPage);
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Image deleted successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
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
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              // Clear the images list when navigating back
              widget.images.clear();
              _pageController.dispose();

              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        body: widget.images.isEmpty
            ? Center(
                child: Text(
                  "No images captured",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        String fileName = widget.images[index].path
                            .split('/')
                            .last;
                        return Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.file(
                                    widget.images[index],
                                    height: 400,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          "Error loading image",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    fileName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteImage(index),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _currentPage == index
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Image.file(
                              widget.images[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey,
                                  child: Center(
                                    child: Text(
                                      "Error",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 30,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Add Image",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Select Image Source"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // Navigator.pop(context);
                                      _addImageFromCamera();
                                    },
                                    child: Text("Camera"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Navigator.pop(context);
                                      _addImageFromGallery();
                                    },
                                    child: Text("Gallery"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 30,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Upload Images",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientInfo(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
