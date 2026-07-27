import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class ProductCard extends GetView<HomeController> {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final images =
        (product["product_images"] ?? []) as List;

    final seller =
        product["profiles"] as Map<String, dynamic>?;

    final city =
        product["cities"] as Map<String, dynamic>?;

    final image = images.isNotEmpty
        ? images.first["image_url"]
        : "";

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          "/product-details",
          arguments: product,
        );
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// IMAGE
            Expanded(
              flex: 5,
              child: Stack(
                children: [

                  Positioned.fill(
                    child: image.isEmpty
                        ? Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image,
                              size: 45,
                            ),
                          )
                        : Image.network(
                            image,
                            fit: BoxFit.cover,
                          ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          Colors.white,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          controller
                                  .isFavourite(
                                      product)
                              ? Icons.favorite
                              : Icons
                                  .favorite_border,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          controller
                              .toggleFavourite(
                            product["id"],
                          );
                        },
                      ),
                    ),
                  ),

                  if (product["is_featured"] ==
                      true)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.orange,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),
                        child: const Text(
                          "FEATURED",
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontSize: 10,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// DETAILS
            Expanded(
              flex: 4,
              child: Padding(
                padding:
                    const EdgeInsets.all(
                        10),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [

                    Text(
                      product["title"] ??
                          "",
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                        height: 4),

                    Text(
                      "£${product["price"]}",
                      style:
                          const TextStyle(
                        color:
                            Colors.green,
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 18,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [

                        const Icon(
                          Icons.location_on,
                          size: 15,
                          color:
                              Colors.grey,
                        ),

                        Expanded(
                          child: Text(
                            city?["name"] ??
                                "",
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 5),

                    Row(
                      children: [

                        CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              seller?[
                                          "avatar_url"] !=
                                      null
                                  ? NetworkImage(
                                      seller![
                                          "avatar_url"],
                                    )
                                  : null,
                          child: seller?[
                                      "avatar_url"] ==
                                  null
                              ? const Icon(
                                  Icons.person,
                                  size: 15,
                                )
                              : null,
                        ),

                        const SizedBox(
                            width: 6),

                        Expanded(
                          child: Text(
                            seller?[
                                    "full_name"] ??
                                "",
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),

                        if (seller?[
                                "is_verified"] ==
                            true)
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 16,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}