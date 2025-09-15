import 'package:flutter/material.dart';
// дизайн кнопок для настроек

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // квадратные углы
        ),
        
      ),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24.0),
          SizedBox(width: 10.0),
          Text(text),
        ],
      ),
    );
  }
}
