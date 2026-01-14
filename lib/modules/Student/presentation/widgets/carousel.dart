import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class DashboardCarousel extends StatelessWidget {
  const DashboardCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: CarouselSlider(
        items: [
          _buildSlide("assets/1.png"),
          _buildSlide("assets/2.png"),
          _buildSlide("assets/3.png"),
          _buildSlide("assets/4.png"),
         _buildSlide("assets/5.png"), 
         
        ],
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          viewportFraction: 1,
          enlargeCenterPage: false,
        ),
      ),
    );
  }

  Widget _buildSlide(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        image,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
