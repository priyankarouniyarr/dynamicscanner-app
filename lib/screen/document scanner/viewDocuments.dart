import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamicemrapp/screen/api/api_client.dart';
import 'package:dynamicemrapp/model/patient_for_scanner_client_view_model.dart';

class Viewdocuments extends StatefulWidget {
  const Viewdocuments({super.key});

  @override
  State<Viewdocuments> createState() => _ViewdocumentsState();
}

class _ViewdocumentsState extends State<Viewdocuments> {
  final TextEditingController _mrnController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  PatientForScannerClientViewModel? _patient;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mrnController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatient(String mrn) async {
    if (mrn.isEmpty) {
      setState(() {
        _patient = null;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final patient = await _apiClient.getPatientByMrn(mrn);
      setState(() {
        _patient = patient;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _patient = null;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Information Documents';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E1948), // Deep purple
            Color(0xFF4A2B7A), // Vibrant purple
            Color(0xFF5D1049), // Magenta accent
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            appTitle,
            style: GoogleFonts.poppins(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _mrnController,
                  decoration: InputDecoration(
                    labelText: 'Enter MRN',
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    floatingLabelStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                  onChanged: (value) => _fetchPatient(value),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),

                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_patient != null)
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Details',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E1948),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Patient Name',
                          _patient!.fullName ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'ID',
                          _patient!.id?.toString() ?? 'N/A',
                        ),
                        _buildDetailRow('Gender', _patient!.gender ?? 'N/A'),
                        _buildDetailRow(
                          'Date of Birth',

                          _patient!.dateOfBirth ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
