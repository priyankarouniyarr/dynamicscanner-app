import 'package:flutter/material.dart';
import 'package:dynamicemrapp/screen/sign%20in/signIn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSetting extends StatelessWidget {
  AppSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'API Setting';

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        centerTitle: true,
        leading: BackButton(color: Colors.black),
      ),

      body: const AppSettingForm(), // body
    );
  }
}

// Create a Form widget.
class AppSettingForm extends StatefulWidget {
  const AppSettingForm({Key? key}) : super(key: key);

  @override
  AppSettingFormState createState() {
    return AppSettingFormState();
  }
}

class AppSettingFormState extends State<AppSettingForm> {
  // Create a global key that uniquely identifies the Form widget
  final _formKey = GlobalKey<FormState>();
  final apiPathController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadForm();
    // Add listener to focus node to rebuild when focus changes
    _focusNode.addListener(() {
      setState(() {});
    });
    // Add listener to text controller to rebuild when text changes
    apiPathController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadForm() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      apiPathController.text = (prefs.getString('DynamicEmrApiPath') ?? "");
    });
  }

  Future<void> _setApiPath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('DynamicEmrApiPath', apiPathController.text);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => SignIn()),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    // Clean up the controller and focus node when the widget is disposed.
    apiPathController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the text field has focus or contains text
    bool isActive = _focusNode.hasFocus || apiPathController.text.isNotEmpty;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              controller: apiPathController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Enter API Path',
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 253, 253),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                  ), // Highlight on focus
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter API path';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _setApiPath();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Data Saved',
                          style: TextStyle(fontSize: 16),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive
                      ? Colors.blueAccent
                      : Colors.grey[200],
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
