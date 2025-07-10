import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // List<dynamic> onboardingPages = [];
  final PageController _controller = PageController();
  int currentIndex = 0;

  List<Map<String, String>> onboardingPages = [
    {
      "image": AppImages.onBoardingImage1,
      "title": "Save time, save money and",
      "highlight": "safe ride",
      "description":
          "Use your smartphone to order a ride, get picked up by a nearby driver, and enjoy a low-cost trip to your destination.",
    },
    {
      "image": AppImages.onBoardingImage2,
      "title": "Get connected with",
      "highlight": "nearby drivers",
      "description":
          "Quickly match with reliable drivers around you for faster pickups and better service.",
    },
    {
      "image": AppImages.onBoardingImage3,
      "title": "Enjoy a ride with",
      "highlight": "full comfort",
      "description":
          "Relax in well-maintained vehicles while your driver takes care of the road.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white2,
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingPages.length,
              onPageChanged: (index) => setState(() => currentIndex = index),
              itemBuilder: (context, index) {
                final page = onboardingPages[index];
                return Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        page['image']!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingPages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      currentIndex == index
                          ? AppColor.primary
                          : AppColor.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: "${onboardingPages[currentIndex]['title']!} ",
                      style: AppTextStyle.paragraph5(AppColor.blackText),
                      children: [
                        TextSpan(
                          text: onboardingPages[currentIndex]['highlight'],
                          style: AppTextStyle.paragraph5(AppColor.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    onboardingPages[currentIndex]['description']!,
                    style: AppTextStyle.subtext4(AppColor.grey),
                  ),
                  const Spacer(),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (currentIndex < onboardingPages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AuthScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      currentIndex == onboardingPages.length - 1
                          ? "GET STARTED"
                          : "NEXT",
                      style: AppTextStyle.paragraph1(AppColor.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
