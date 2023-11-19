import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FakeHabitListTile extends StatelessWidget {
  const FakeHabitListTile({super.key});


  @override
    Widget build(BuildContext context) => Shimmer.fromColors(
     baseColor:const Color.fromARGB(188, 107, 107, 107),
    highlightColor:const Color.fromARGB(187, 194, 194, 194),
    period: const Duration(milliseconds: 1500),
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      decoration: BoxDecoration(
        color: const Color.fromARGB(188, 107, 107, 107),
        borderRadius: BorderRadius.circular(10)
      ),
    ),
  );
 }