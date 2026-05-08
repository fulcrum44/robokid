import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robokid/theme/app_theme.dart';

class LoginFormWidget extends StatelessWidget {
  final String? hintText;
  final IconData? icon;
  final IconButton? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final String? prefixText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? enabled;
 final List<TextInputFormatter>? inputFormatter;
  final String? Function(String?)? validator;
  
  const LoginFormWidget({
    super.key,
    this.hintText,
    this.icon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.maxLength,
    this.inputFormatter,
    this.prefixText,
    this.controller,
    this.focusNode,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderColor = theme.brightness == Brightness.light
        ? AppTheme.robokids
        : Colors.white;

    return TextFormField(
      style: TextStyle(color: theme.textTheme.titleSmall?.color),
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      validator: validator,
      inputFormatters: inputFormatter ?? [],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(color: borderColor, width: 2.0),
        ),
        counterText: '',
        prefixText: prefixText,
      ),
    );
  }
}