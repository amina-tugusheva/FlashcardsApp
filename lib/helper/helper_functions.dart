import 'package:flutter/material.dart';

//
void displayMassageToUser(String message, BuildContext context){
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Text(message),

    ),
  );
}