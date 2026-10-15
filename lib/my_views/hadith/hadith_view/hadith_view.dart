import 'package:flutter/material.dart';
import 'package:risala/my_views/hadith/custom/custom_chapter_list.dart';

class HadithView extends StatefulWidget {
  const HadithView({super.key});

  @override
  State<HadithView> createState() => _HadithViewState();
}

class _HadithViewState extends State<HadithView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: CustomChapterList(),
    );
  }
}
