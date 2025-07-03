import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../model/scan_document_dto.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dynamicemrapp/screen/homepage.dart';
import 'package:dynamicemrapp/screen/api/api_client.dart';
import 'package:dynamicemrapp/model/scan_document_master_dto.dart';
import '../../model/patient_registration_for_scanner_client_view_model.dart';
import 'package:dynamicemrapp/model/patient_for_scanner_client_view_model.dart';

class PatientInfo extends StatelessWidget {
  PatientInfo({Key? key}) : super(key: key);

  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Patient Information';

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
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Text(
              appTitle,
              style: GoogleFonts.poppins(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: PatientInfoForm(scaffoldMessengerKey: _scaffoldMessengerKey),
        ),
      ),
    );
  }
}

class PatientInfoForm extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const PatientInfoForm({super.key, required this.scaffoldMessengerKey});

  @override
  PatientInfoFormState createState() {
    return PatientInfoFormState();
  }
}

class PatientInfoFormState extends State<PatientInfoForm> {
  final _formKey = GlobalKey<FormState>();

  final ApiClient _apiClient = ApiClient();
  final patientNameTextField = TextEditingController();
  final scrollController = ScrollController();
  String dropdownValue = 'One';
  int _patientRegistrationId = 0;
  String _serviceType = "";
  String _pictureSource = "";
  String _pictureType = "";
  String _isScanComplete = "";

  late Future<List<PatientRegistrationForScannerClientViewModel>> visits;
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    List<PatientRegistrationForScannerClientViewModel> visitList = [];
    visits = Future.value(visitList);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    patientNameTextField.dispose();
    scrollController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<String>> get serviceTypeDropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(value: "OPD", child: Text("OPD")),
      DropdownMenuItem(value: "IPD", child: Text("IPD")),
    ];
    return menuItems;
  }

  List<DropdownMenuItem<String>> get pictureSourceDropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(value: "NA", child: Text("NA")),
      DropdownMenuItem(value: "OPD", child: Text("OPD")),
      DropdownMenuItem(value: "IPD", child: Text("IPD")),
      DropdownMenuItem(value: "OT", child: Text("OT")),
      DropdownMenuItem(value: "Diagnostic", child: Text("Diagnostic")),
      DropdownMenuItem(value: "Lab", child: Text("Lab")),
      DropdownMenuItem(value: "Subspecialty", child: Text("Subspecialty")),
    ];
    return menuItems;
  }

  List<DropdownMenuItem<String>> get pictureTypeDropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(value: "NA", child: Text("NA")),
      DropdownMenuItem(value: "OPDCARD", child: Text("OPDCARD")),
      DropdownMenuItem(value: "DISCHARGECARD", child: Text("DISCHARGECARD")),
    ];
    return menuItems;
  }

  List<DropdownMenuItem<String>> get isScanCompleteDropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(value: "No", child: Text("No")),
      DropdownMenuItem(value: "Yes", child: Text("Yes")),
    ];
    return menuItems;
  }

  List<DropdownMenuItem<String>> get defaultDropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(value: "", child: Text("Select One")),
    ];
    return menuItems;
  }

  Future<void> _loadPatientAsync(String mrn) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (!mounted) return;
      PatientForScannerClientViewModel patientVisits = await _apiClient
          .getPatientByMrn(mrn);
      patientNameTextField.text = patientVisits.fullName;
      List<PatientRegistrationForScannerClientViewModel> visitlist =
          List<PatientRegistrationForScannerClientViewModel>.from(
            patientVisits.visits.map(
              (model) =>
                  PatientRegistrationForScannerClientViewModel.fromJson(model),
            ),
          );
      visits = Future.value(visitlist);
      if (mounted) setState(() {});
    });
  }

  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen(
      (file) => files.add(file),
      onDone: () => completer.complete(files),
    );
    return completer.future;
  }

  Future<void> _showConfirmationDialog() async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Submission'),
          content: Text('Are you sure you want to submit the form?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleSubmission();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmission() async {
    if (!mounted || !(_formKey.currentState?.validate() ?? false)) {
      if (mounted) {
        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Please fill all required fields"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_patientRegistrationId == 0 ||
        _serviceType.isEmpty ||
        _pictureSource.isEmpty ||
        _pictureType.isEmpty ||
        _isScanComplete.isEmpty) {
      if (mounted) {
        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Please fill all the above required fields."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    String appDocPath = "";
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory appDocDirFolder = Directory(
        '${appDocDir.path}/DynamicEmrScan/',
      );
      final Directory appScanFolder = await appDocDirFolder.create(
        recursive: true,
      );
      appDocPath = appScanFolder.path;
      print("App Document Path: $appDocPath");

      List<FileSystemEntity> folderFiles = await dirContents(appScanFolder);
      List<ScanDocumentDto> docs = [];
      var fileIndex = 0;

      if (folderFiles.isEmpty) {
        if (mounted) {
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text("No file to upload"),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      for (var entity in folderFiles) {
        if (await FileSystemEntity.isFile(entity.path)) {
          var f = File(entity.path);
          List<int> imageBytes = await f.readAsBytes();
          String base64Image = base64Encode(imageBytes);
          print("Base64 image length for ${f.path}: ${base64Image.length}");
          ScanDocumentDto docDto = ScanDocumentDto(
            base64Image,
            fileIndex,
            _patientRegistrationId,
          );
          docs.add(docDto);
          fileIndex++;
        }
      }

      ScanDocumentMasterDto parameterObj = ScanDocumentMasterDto(
        docs,
        _serviceType,
        _pictureSource,
        _isScanComplete,
        _pictureType,
      );

      bool isSuccess = await _apiClient.uploadImages(
        _patientRegistrationId,
        parameterObj,
      );

      if (isSuccess) {
        for (var entity in folderFiles) {
          if (await FileSystemEntity.isFile(entity.path)) {
            var f = File(entity.path);
            await f.delete();
          }
        }

        if (mounted) {
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text("Upload successfully"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(Duration(seconds: 2));

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
              (route) => false,
            );
          }
        }
      } else {
        if (mounted) {
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text("Could not upload"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Upload error: $e");
      if (mounted) {
        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Upload failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...[
                TextFormField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Mrno',
                    labelText: 'Mrno',
                  ),
                  onChanged: (value) {
                    setState(() {
                      log(value);
                      _loadPatientAsync(value);
                    });
                  },
                ),
                FutureBuilder<
                  List<PatientRegistrationForScannerClientViewModel>
                >(
                  future: visits,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return DropdownButtonFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            labelText: 'Patient Visit ',
                          ),
                          items: snapshot.data
                              ?.map(
                                (
                                  PatientRegistrationForScannerClientViewModel
                                  item,
                                ) => DropdownMenuItem<String>(
                                  value: item.registrationId.toString(),
                                  child: Text(
                                    "[Visit:${item.visitCount.toString()}] ${DateFormat('MM/dd/yyyy').format(item.registrationDate)}  [${item.registrationTypeName}] \n [Dpt: ${item.department}]",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _patientRegistrationId =
                                  int.tryParse(value.toString()) ?? 0;
                              print(
                                "_patientRegistrationID:$_patientRegistrationId",
                              );
                            });
                          },
                        );
                      } else {
                        return DropdownButtonFormField(
                          items: defaultDropdownItems,
                          onChanged: (value) {
                            setState(() {});
                          },
                        );
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                TextFormField(
                  controller: patientNameTextField,
                  readOnly: true,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Patient Name',
                    labelText: 'Patient Name',
                  ),
                  onChanged: (value) {},
                ),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Service Type',
                  ),
                  items: serviceTypeDropdownItems,
                  hint: Text("Service Type"),
                  onChanged: (value) {
                    setState(() {
                      _serviceType = value.toString();
                    });
                  },
                ),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Picture Source',
                  ),
                  items: pictureSourceDropdownItems,
                  hint: Text("Picture Source"),
                  onChanged: (value) {
                    setState(() {
                      _pictureSource = value.toString();
                    });
                  },
                ),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Picture Type',
                  ),
                  items: pictureTypeDropdownItems,
                  hint: Text("Picture Type"),
                  onChanged: (value) {
                    setState(() {
                      _pictureType = value.toString();
                    });
                  },
                ),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Is Scan Complete',
                  ),
                  items: isScanCompleteDropdownItems,
                  onChanged: (value) {
                    setState(() {
                      _isScanComplete = value.toString();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          _formKey.currentState?.reset();
                          patientNameTextField.clear();
                        });
                        widget.scaffoldMessengerKey.currentState?.showSnackBar(
                          SnackBar(
                            content: Text(
                              "Form reset successful",
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _patientRegistrationId != 0 &&
                                _serviceType.isNotEmpty &&
                                _pictureSource.isNotEmpty &&
                                _pictureType.isNotEmpty &&
                                _isScanComplete.isNotEmpty
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                      onPressed: _isLoading ? null : _showConfirmationDialog,
                    ),
                  ],
                ),
              ].expand((widget) => [widget, const SizedBox(height: 24)]),
            ],
          ),
        ),
      ),
    );
  }
}
