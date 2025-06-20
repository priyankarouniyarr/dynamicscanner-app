import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamicemrapp/FaCardDetails.dart';
import 'package:dynamicemrapp/screen/sign%20in/signIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamicemrapp/screen/document%20scanner/AddImage.dart';
import 'package:dynamicemrapp/check_connection.dart' show CheckConnection;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String username = '';

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Center(child: const Text('')),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.lock_person_rounded),
              tooltip: 'Log Out',
              color: Colors.redAccent,
              iconSize: 35,
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('DynamicEmrLoginToken');
                await prefs.remove('DyanmicEmrLoginExpiration');
                await prefs.remove('DyanmicEmrLoginBranchId');
                await prefs.remove('username');
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text("Logout successfully"),
                        ],
                      ),
                    ),
                  ),
                );

                await Future.delayed(const Duration(seconds: 2));

                Navigator.of(context).pop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hi, ${username.isNotEmpty ? username : ''}\n',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 45,
                            fontWeight: FontWeight.w900,
                            wordSpacing: 0.5,
                            letterSpacing: 0.5,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),

                        TextSpan(
                          text: 'How can I help you today?',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                            wordSpacing: 0.5,
                            letterSpacing: 0.5,
                            color: const Color.fromARGB(255, 220, 210, 210),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 30,
                  childAspectRatio: 1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ActionButton(
                      label: "Document Scanner",
                      icon: Icons.qr_code_scanner,
                      colors: Colors.blue,
                      color: Colors.blue.shade100,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddImage()),
                        );
                      },
                    ),
                    _ActionButton(
                      label: "FA Barcode Scanner",
                      icon: Icons.barcode_reader,
                      colors: Colors.blue,
                      color: Colors.grey.shade200,
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => FaBarcodeScanner(),
                        //   ),
                        // );
                      },
                    ),
                    // _ActionButton(
                    //   label: "FA Details",
                    //   colors: Colors.blue,
                    //   icon: Icons.menu_book_rounded,
                    //   color: Colors.green.shade100,
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => const AccordionPage(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    // _ActionButton(
                    //   label: "Check User Connection",
                    //   icon: Icons.network_wifi,
                    //   colors: Colors.blue,

                    //   color: const Color.fromARGB(255, 148, 243, 255),
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (_) => CheckConnection()),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color colors;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: colors),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
