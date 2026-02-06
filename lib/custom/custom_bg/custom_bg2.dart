import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomBg2 extends StatelessWidget {
  const CustomBg2({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height,
              color: whiteColor,
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height,
              color: scandColor,
            ),
          ],
        ),
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              decoration: const BoxDecoration(
                  color: whiteColor,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(200))),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                  color: scandColor,
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(200))),
            ),
          ],
        ),
      ],
    );
  }
}
