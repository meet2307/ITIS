import 'package:flutter/material.dart';
import 'package:itis_project_python/pallete.dart';


class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback press;
  const GradientButton({Key? key,required this.label, required this.press}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Pallete.gradient1,
            Pallete.gradient2,
            Pallete.gradient3,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: () {
          press;
        },
        style:
          ElevatedButton.styleFrom(
          fixedSize: const Size(395, 55),
          shadowColor: Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}