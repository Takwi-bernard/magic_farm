import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {

  final TextEditingController controller;
  final Function(String)? onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: "Search products...",
        prefixIcon: Icon(Icons.search),
      ),
    );

  }
}