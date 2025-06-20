import '../api/api_client.dart';
import '../../model/branch.dart';
import 'package:flutter/material.dart';
import '../appsetting/appSettings.dart';
import '../../model/login_response.dart';
import '../../model/credential_model.dart';
import 'package:dynamicemrapp/screen/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamicemrapp/screen/sign%20in/passwordfield.dart';

class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignInForm(), // body
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppSetting()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.settings),
      ),
    );
  }
}

// Create a Form widget.
class SignInForm extends StatefulWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  SignInFormState createState() {
    return SignInFormState();
  }
}

class SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final apiPathController = TextEditingController();
  final ApiClient _apiClient = ApiClient();

  CredentialModel formData = CredentialModel("", "", 0);

  String dropdownValue = 'One';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _setJwtToken(loginResponse, int branchId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('DynamicEmrLoginToken', loginResponse.token);
      prefs.setString(
        'DyanmicEmrLoginExpiration',
        loginResponse.expiration.toString(),
      );
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

  List<DropdownMenuItem<String>> get defaultDropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Select One"), value: ""),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...[
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Username Container
                TextFormField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Your username',
                    labelText: 'Username',
                    border: OutlineInputBorder(),

                    // 👇 Add this for the icon
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    formData.username = value;
                  },
                ),

                // Password Container
                PasswordField(
                  onChanged: (value) {
                    formData.password = value;
                  },
                ),

                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: FutureBuilder<List<Branch>>(
                    future: _loadBranchesAsync(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButtonFormField(
                            isExpanded: true, // Ensures the dropdown expands

                            items: snapshot.data
                                ?.map(
                                  (Branch item) => DropdownMenuItem<String>(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ), // Adds space around the text
                                      child: Text(item.branchName),
                                    ),
                                    value: item.id.toString(),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                formData.branchId = int.parse(value.toString());
                              });
                            },
                          ),
                        );
                      } else {
                        return DropdownButtonHideUnderline(
                          child: DropdownButtonFormField(
                            isExpanded: true,

                            items: defaultDropdownItems,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),

                ElevatedButton(
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () async {
                    try {
                      LoginResponse loginResponse = await _apiClient.login(
                        formData,
                      );
                      _setJwtToken(loginResponse, formData.branchId);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );

                      print(loginResponse);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unable to login.',
                            style: TextStyle(fontSize: 16),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ].expand((widget) => [widget, const SizedBox(height: 24)]),
            ],
          ),
        ),
      ),
    );
  }
}
