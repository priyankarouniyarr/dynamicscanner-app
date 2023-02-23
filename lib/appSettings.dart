import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dynamicemrapp/signIn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSetting extends StatelessWidget {
  AppSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'API Setting';

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      body: const AppSettingForm(), // body
    );   
  }
}

// Create a Form widget.
class AppSettingForm extends StatefulWidget {
  //const MyCustomForm({super.key});
  const AppSettingForm({Key? key}) : super(key: key);

  @override
  AppSettingFormState createState() {
    return AppSettingFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class AppSettingFormState extends State<AppSettingForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final apiPathController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  //Loading counter value on start
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
        MaterialPageRoute(
          builder: (BuildContext context) => SignIn(),
        ),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    apiPathController.dispose();   
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: apiPathController,
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter api path';
              }
              return null;
            },
          ),          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  _setApiPath();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data Saved')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
