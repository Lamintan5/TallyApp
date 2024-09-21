import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    final color =Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    return Container(
      alignment: Alignment.center,
      child: SpinKitSquareCircle(
        color: color,
        size: 50.0,
      ),
    ) ;
  }
}
