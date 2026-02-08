import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomTimeField extends StatefulWidget {
  const CustomTimeField({super.key, required this.hintText});
  final String hintText;
  @override
  State<CustomTimeField> createState() =>
      CustomTimeFieldState(); // بدل _CustomTimeFieldState
}

// بدل class _CustomTimeFieldState
class CustomTimeFieldState extends State<CustomTimeField> {
  final TextEditingController controller = TextEditingController();
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: scandColor, width: 2),
        ),
        hintTextDirection: TextDirection.rtl,
        filled: true,
        fillColor: mainColor,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.access_time),
      ),
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null) {
          setState(() {
            selectedTime = pickedTime;
            controller.text = pickedTime.format(context);
          });
        }
      },
    );
  }
}
