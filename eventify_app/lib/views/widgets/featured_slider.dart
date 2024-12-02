import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/my_data.dart';

class SliderController extends GetxController {
  var currentIndex = 0.obs;
}

Widget featuredSlider() {
  final SliderController sliderController = Get.put(SliderController());

  return Column(
    children: [
      // Carousel slider
      CarouselSlider(
        options: CarouselOptions(
          height: 150,
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 6 / 4,
          autoPlayInterval: const Duration(seconds: 6),
          viewportFraction: 1,
          padEnds: false,
          onPageChanged: (index, reason) {
            sliderController.currentIndex.value =
                index; // Update index using GetX
          },
        ),
        items: events.map((event) {
          return Builder(
            builder: (BuildContext context) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Stack(
                  children: [
                    // Background image
                    Container(
                      width: MediaQuery.of(context)
                          .size
                          .width, // Full screen width
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                          image: AssetImage(event['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 200,
                    ),

                    // Transparent black
                    Container(
                      width: MediaQuery.of(context)
                          .size
                          .width, // Full screen width
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      height: 200,
                    ),

                    // Event title
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          event['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),

      // Progress dots
      Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            events.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: sliderController.currentIndex.value == index
                  ? 12
                  : 8, // Active dot is bigger
              height: 8,
              decoration: BoxDecoration(
                color: sliderController.currentIndex.value == index
                    ? Colors.blue
                    : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    ],
  );
}
