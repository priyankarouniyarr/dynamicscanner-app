import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final Function(String) onChanged;
  const PasswordField({super.key, required this.onChanged});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Password',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(Icons.password),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
      onChanged: widget.onChanged,
    );
  }
}
