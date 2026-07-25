import 'package:flutter/material.dart';

class BackgroundShapes extends StatelessWidget {
  const BackgroundShapes({super.key});

  @override
  Widget build(BuildContext context) {

    return Stack(

      children: [

        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(.05),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.04),
              shape: BoxShape.circle,
            ),
          ),
        ),

      ],

    );
  }
}