import 'package:flutter/material.dart';

class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SearchBarField({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'PublicSans',
        fontSize: 14,
        color: Color(0xFF0D1B2A),
      ),
      decoration: InputDecoration(
        hintText: 'Cari berdasarkan judul, kata kunci, atau ID...',
        hintStyle: TextStyle(
          fontFamily: 'PublicSans',
          fontSize: 14,
          color: Colors.grey.shade400,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Colors.grey.shade500,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1A2B5F), width: 1.5),
        ),
      ),
    );
  }
}
