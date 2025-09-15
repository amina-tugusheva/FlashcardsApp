import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String secondName;
  final Icon iconName;
  final void Function()? onPressed;

  const MyTextBox({
    super.key,
    required this.text,
    required this.secondName,
    required this.iconName,
    required this.onPressed,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),

      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(secondName),

              IconButton(
                onPressed: onPressed, 
              icon: iconName,
              
              ),
            ],
          ),

          Text(text),
        ],
      ),

    );
    
  }
}