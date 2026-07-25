import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {

  final String title;

  final String subtitle;

  final IconData icon;

  const EmptyStateWidget({

    super.key,

    required this.title,

    required this.subtitle,

    this.icon = Icons.inbox,

  });

  @override
  Widget build(BuildContext context) {

    return Center(

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(icon,size:80),

          const SizedBox(height:20),

          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:22),
          ),

          const SizedBox(height:8),

          Text(subtitle),

        ],

      ),

    );

  }

}