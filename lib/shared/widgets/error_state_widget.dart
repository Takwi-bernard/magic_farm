import 'package:flutter/material.dart';

import 'primary_button.dart';

class ErrorStateWidget extends StatelessWidget {

  final String message;

  final VoidCallback onRetry;

  const ErrorStateWidget({

    super.key,

    required this.message,

    required this.onRetry,

  });

  @override
  Widget build(BuildContext context) {

    return Center(

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          const Icon(

            Icons.error_outline,

            size:80,

            color: Colors.red,

          ),

          const SizedBox(height:20),

          Text(message),

          const SizedBox(height:20),

          PrimaryButton(

            text:"Retry",

            onPressed:onRetry,

          )

        ],

      ),

    );

  }

}