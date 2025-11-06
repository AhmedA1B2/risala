import 'package:flutter/material.dart';

class MoadhnView extends StatefulWidget {
  const MoadhnView({super.key});

  @override
  State<MoadhnView> createState() => _MoadhnViewState();
}

class _MoadhnViewState extends State<MoadhnView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(onPressed: () {}, child: const Text("data")),
      ),
    );
  }
}
