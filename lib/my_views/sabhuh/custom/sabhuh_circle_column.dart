import 'package:flutter/material.dart';
import 'package:risala/my_views/sabhuh/custom/sabhuh_circle.dart';

class SabhuhCircleColumn extends StatelessWidget {
  const SabhuhCircleColumn(
      {super.key, required this.inColor, required this.outColor});
  final List<Color> inColor;
  final List<Color> outColor;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10,
      bottom: 0,
      top: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SabhuhCircle(
            inColor: inColor[0],
            outColor: outColor[0],
          ),
          SabhuhCircle(
            inColor: inColor[1],
            outColor: outColor[1],
          ),
          SabhuhCircle(
            inColor: inColor[2],
            outColor: outColor[2],
          ),
          SabhuhCircle(
            inColor: inColor[3],
            outColor: outColor[3],
          ),
          SabhuhCircle(
            inColor: inColor[4],
            outColor: outColor[4],
          ),
        ],
      ),
    );
  }
}
