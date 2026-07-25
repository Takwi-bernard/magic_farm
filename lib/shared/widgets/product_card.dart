import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_colors.dart';
import 'network_image_widget.dart';

class ProductCard extends StatelessWidget {

  final String image;

  final String title;

  final String location;

  final double price;

  final bool favorite;

  final VoidCallback onTap;

  final VoidCallback onFavorite;

  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.location,
    required this.price,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Card(

        elevation: 2,

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Stack(

              children: [

                NetworkImageWidget(

                  imageUrl: image,

                  height: 180,

                  width: double.infinity,

                ),

                Positioned(

                  right: 8,

                  top: 8,

                  child: CircleAvatar(

                    backgroundColor: Colors.white,

                    child: IconButton(

                      onPressed: onFavorite,

                      icon: Icon(

                        favorite
                            ? Icons.favorite
                            : Icons.favorite_border,

                        color: Colors.red,

                      ),

                    ),

                  ),

                )

              ],

            ),

            Padding(

              padding:
                  const EdgeInsets.all(12),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style:
                        AppTextStyles.title,
                  ),

                  const SizedBox(height: 8),

                  Text(location),

                  const SizedBox(height: 8),

                  Text(

                    "XAF ${price.toStringAsFixed(0)}",

                    style: const TextStyle(

                      color: AppColors.primary,

                      fontWeight: FontWeight.bold,

                      fontSize: 18,

                    ),

                  )

                ],

              ),

            )

          ],

        ),

      ),

    );

  }

}