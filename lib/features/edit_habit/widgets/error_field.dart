import 'package:flutter/material.dart';

class ErrorField extends StatelessWidget {
  const ErrorField({super.key, required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)),border: Border.all(color: Colors.red)),
        padding: const EdgeInsets.symmetric(horizontal:10, vertical: 5),
        margin: const EdgeInsets.only(top: 5),
        child: Text(
          error,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Colors.red),
        ));
  }
}
