import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key, required this.onTap});
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/no_internet.json',
            width: 200.h,
            height: 200.h,
            fit: BoxFit.fill,
          ),
          const Text(
            "Whoops!!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: const Text(
              "No Internet connection was found. Check your connection or try again.",
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 40.h,
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 44.h,
              width: Get.width * 0.8,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(30.r)),
                  boxShadow: [
                    BoxShadow(
                        color: Get.theme.primaryColor.withOpacity(0.3),
                        blurRadius: 4.0,
                        offset: const Offset(0.0, 5.0)),
                  ],
                  color: const Color(0xFF14f74d)),
              alignment: Alignment.center,
              child: const Text(
                "Try again",
                style:
                    TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
