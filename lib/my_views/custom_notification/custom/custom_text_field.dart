import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10), // مسافة خارجية
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), // زوايا دائرية للحاوية
        boxShadow: const [
          // إضافة ظل خفيف لإعطاء عمق
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        cursorColor: scandColor,
        textDirection: TextDirection.rtl,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintTextDirection: TextDirection.rtl,
          filled: true,
          fillColor: mainColor,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon:
              prefixIcon != null ? Icon(prefixIcon, color: scandColor) : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: scandColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: dilutionScandColor, width: 2),
          ),
        ),
      ),
    );
  }
}
