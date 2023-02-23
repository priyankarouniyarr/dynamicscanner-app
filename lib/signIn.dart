import 'dart:convert';
import 'package:flutter/material.dart';
import 'model/credential_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apiclient.dart';
import 'appSettings.dart';
import 'model/branch.dart';
import 'model/login_response.dart';
import 'main.dart';


class SignIn extends StatelessWidget {
  //const AppSetting({super.key});
  SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Sign In';

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      body: const SignInForm(), // body
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AppSetting()));
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.settings),
      ),
    );
  }
}

// Create a Form widget.
class SignInForm extends StatefulWidget {
  //const MyCustomForm({super.key});
  const SignInForm({Key? key}) : super(key: key);

  @override
  SignInFormState createState() {
    return SignInFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class SignInFormState extends State<SignInForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final apiPathController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  //List<DropdownMenuItem<String>> menuItems = [];
  // late Future<List<Branch>> futureBranch;

  CredentialModel formData = CredentialModel("", "", 0);

  String dropdownValue = 'One';

  @override
  void initState() {
    super.initState();
    //_loadBranches();
  }

  Future<void> _setJwtToken(loginResponse, int branchId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('DynamicEmrLoginToken', loginResponse.token);
      prefs.setString(
          'DyanmicEmrLoginExpiration', loginResponse.expiration.toString());
      prefs.setInt('DyanmicEmrLoginBranchId', branchId);
    });
  }

  Future<List<Branch>> _loadBranchesAsync() async {
    List<Branch> branches = await _apiClient.getBranches();
    return branches;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    apiPathController.dispose();
    super.dispose();
  }

  // List<DropdownMenuItem<String>> get dropdownItems {
  //   List<DropdownMenuItem<String>> menuItems = [
  //     DropdownMenuItem(child: Text("Branch 1"), value: "Branch 1"),
  //     DropdownMenuItem(child: Text("Branch 2"), value: "Branch 2"),
  //     DropdownMenuItem(child: Text("Branch 3"), value: "Branch 3"),
  //     DropdownMenuItem(child: Text("Branch 4"), value: "Branch 4"),
  //   ];
  //   return menuItems;
  // }

  List<DropdownMenuItem<String>> get defaultDropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Select One"), value: ""),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.

    return Form(
      key: _formKey,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...[
                TextFormField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Your username',
                    labelText: 'username',
                  ),
                  onChanged: (value) {
                    formData.username = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    formData.password = value;
                  },
                ),
                // DropdownButtonFormField(
                //   decoration: const InputDecoration(
                //     filled: true,
                //     labelText: 'Branch',
                //   ),
                //   items: menuItems,
                //   hint: Text("Branch"),
                //   onChanged: (value) {
                //     setState(() {});
                //   },
                // ),
                FutureBuilder<List<Branch>>(
                  future: _loadBranchesAsync(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DropdownButtonFormField(
                          items: snapshot.data
                              ?.map((Branch item) => DropdownMenuItem<String>(
                                  child: Text(item.branchName),
                                  value: item.id.toString()))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              formData.branchId = int.parse(value.toString());
                            });
                          });
                    } else {
                      return DropdownButtonFormField(
                          items: defaultDropdownItems,
                          onChanged: (value) {
                            setState(() {});
                          });
                    }
                  },
                ),

                TextButton(
                  child: const Text('Sign in'),
                  onPressed: () async {
                    try {
                      LoginResponse loginResponse =
                          await _apiClient.login(formData);
                      _setJwtToken(loginResponse, formData.branchId);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage()));

                      print(loginResponse);

                      //String responseJson = json.encode(loginResponse.toJson());
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Unable to login.')),
                      );
                    }

                    // Use a JSON encoded string to send
                    // var result = await widget.httpClient!.post(
                    //     Uri.parse('https://example.com/signin'),
                    //     body: json.encode(formData.toJson()),
                    //     headers: {'content-type': 'application/json'});

                    // if (result.statusCode == 200) {
                    //   _showDialog('Successfully signed in.');
                    // } else if (result.statusCode == 401) {
                    //   _showDialog('Unable to sign in.');
                    // } else {
                    //   _showDialog('Something went wrong. Please try again.');
                    // }
                  },
                ),
              ].expand(
                (widget) => [
                  widget,
                  const SizedBox(
                    height: 24,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
