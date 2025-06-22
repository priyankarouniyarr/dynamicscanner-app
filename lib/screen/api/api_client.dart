import 'dart:convert';
import 'dart:developer';
import '../../model/branch.dart';
import 'package:http/http.dart' as http;
import '../../model/login_response.dart';
import '../../model/credential_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamicemrapp/model/scan_document_master_dto.dart';
import 'package:dynamicemrapp/model/patient_for_scanner_client_view_model.dart';

class ApiClient {
  Future<List<Branch>> getBranches() async {
    final prefs = await SharedPreferences.getInstance();
    String basePath = (prefs.getString('DynamicEmrApiPath') ?? "");
    var url = Uri.parse(basePath + '/Api/Scanner/GetAllBranchForApi');
    //http://45.117.153.90:5001/Api/Scanner/GetAllBranchForApi
    print(url);
    var response = await http.get(url);

    // print(response.body);

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      List<Branch> branches = List<Branch>.from(
        l.map((model) => Branch.fromJson(model)),
      );
      branches.forEach((element) {});
      return branches;
    } else {
      throw Exception('Failed to load branch');
    }
  }

  //login portion
  Future<LoginResponse> login(CredentialModel crediential) async {
    print("username : password ${crediential.toJson()}");
    final prefs = await SharedPreferences.getInstance();
    String basePath = (prefs.getString('DynamicEmrApiPath') ?? "");

    var url = Uri.parse(basePath + '/UserAdmin/LoginFromApi');
    print(url);
    try {
      var response = await http.post(
        url,
        body: json.encode(crediential.toJson()),
        headers: {'content-type': 'application/json'},
      );
      // print(response.statusCode);
      if (response.statusCode == 200) {
        //   print(json.decode(response.body));
        LoginResponse loginResponse = LoginResponse.fromJson(
          json.decode(response.body),
        );
        // Save username
        await prefs.setString('username', crediential.username);
        return loginResponse;
      } else {
        throw Exception("Fail to login");
      }
    } catch (e) {
      log(e.toString());
      throw e;
    }
  }

  //scanner
  Future<PatientForScannerClientViewModel> getPatientByMrn(String mrn) async {
    final prefs = await SharedPreferences.getInstance();
    String basePath = (prefs.getString('DynamicEmrApiPath') ?? "");
    int branchId = (prefs.getInt("DyanmicEmrLoginBranchId") ?? 0);
    print("branchId: $branchId");
    log("basePath: $basePath");
    var url = Uri.parse(
      basePath + '/Api/Client/GetPatientByMrn/$mrn/${branchId.toString()}',
    );
    print(url);
    final response = await http.get(url);
    print(response.statusCode);
    print(response.statusCode.bitLength);
    if (response.statusCode == 200) {
      log("why");
      log("body: ${response.body}");

      PatientForScannerClientViewModel patientResposne =
          PatientForScannerClientViewModel.fromJson(json.decode(response.body));

      log("Ok success");
      return patientResposne;
    } else {
      log("Error occured");

      throw Exception('Failed to load patient');
    }
  }

  Future<bool> uploadImages(
    int patientRegistrationid,
    ScanDocumentMasterDto dto,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String basePath = (prefs.getString('DynamicEmrApiPath') ?? "");
    String token = (prefs.getString('DynamicEmrLoginToken') ?? "");
    var url = Uri.parse(
      basePath + '/api/Scanner/${patientRegistrationid.toString()}',
    );
    print("Upload URL: $url");
    print("Token: $token");
    var jsonObj = json.encode(dto.toJson());
    print("Request body: $jsonObj");

    try {
      var response = await http.post(
        url,
        body: jsonObj,
        headers: {
          "Authorization": 'Bearer $token',
          "Content-Type": "application/json",
        },
      );
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Upload failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print("Upload error: $e");
      throw Exception('Upload failed: $e');
    }
  } //   Future<bool> checkLoginA() async {
  //     final prefs = await SharedPreferences.getInstance();
  //     String basePath = (prefs.getString('DynamicEmrApiPath') ?? "");
  //     String token = (prefs.getString('DynamicEmrLoginToken') ?? "");
  //     var url = Uri.parse('$basePath/api/Scanner/CheckLoginA');
  //     print(url);

  //     var response = await http.post(
  //       url,
  //       body: null,
  //       headers: {
  //         "Authorization": 'Bearer $token',
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       print(response);
  //       return true;
  //     } else {
  //       print(response);
  //       return false;
  //     }
  //   }

  //   Future<bool> checkLoginB() async {
  //     final prefs = await SharedPreferences.getInstance();
  //     String basePath = (prefs.getString('DynamicEmrApiPath') ?? "");
  //     String token = (prefs.getString('DynamicEmrLoginToken') ?? "");
  //     var url = Uri.parse(basePath + '/api/Scanner/CheckLoginB');
  //     print(url);

  //     var response = await http.post(
  //       url,
  //       body: null,
  //       headers: {
  //         "Authorization": 'Bearer $token',
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       print(response);
  //       return true;
  //     } else {
  //       print(response);
  //       return false;
  //     }
  //   }
  // }
}
//   Future<List<PatientForScannerClientViewModel>> getPatientByMrn(
//       String mrn) async {
//     final prefs = await SharedPreferences.getInstance();
//     String basePath = (prefs.getString('DynamicEmrApiPath') ?? "");
//     int branchId = (prefs.getInt("DyanmicEmrLoginBranchId") ?? 0);
//     var url = Uri.parse(
//         basePath + '/Api/Client/GetPatientByMrn/$mrn/${branchId.toString()}');

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       // If the server did return a 200 OK response,
//       // then parse the JSON.

//       Iterable l = json.decode(response.body);
//       List<PatientForScannerClientViewModel> patientVisits =
//           List<PatientForScannerClientViewModel>.from(l.map(
//               (model) => PatientForScannerClientViewModel.fromJson(model)));
//       patientVisits.forEach((element) {
//         print(element.toJson());
//       });
//       return patientVisits;

//       // return PatientForScannerClientViewModel.fromJson(
//       //     jsonDecode(response.body));
//     } else {
//       // If the server did not return a 200 OK response,
//       // then throw an exception.
//       throw Exception('Failed to load patient');
//     }
//   }
// }
