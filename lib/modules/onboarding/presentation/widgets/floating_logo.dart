import 'package:flutter/material.dart';

class FloatingLogo extends StatefulWidget {

  final String image;

  const FloatingLogo({

    super.key,

    required this.image,

  });

  @override
  State<FloatingLogo> createState()
      => _FloatingLogoState();

}

class _FloatingLogoState
    extends State<FloatingLogo>

    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {

    super.initState();

    controller = AnimationController(

      vsync:this,

      duration:
          const Duration(seconds:3),

    )..repeat(reverse:true);

  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(

      animation:controller,

      builder:(_,child){

        return Transform.translate(

          offset:Offset(
            0,
            controller.value*10,
          ),

          child:child,

        );

      },

      child:Image.asset(
        widget.image,
        height:260,
      ),

    );

  }

  @override
  void dispose(){

    controller.dispose();

    super.dispose();

  }

}