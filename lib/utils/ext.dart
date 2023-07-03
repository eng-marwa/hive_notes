import 'package:flutter/material.dart';

extension Ext on Widget{
  void showSnackBar(BuildContext context , String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

}