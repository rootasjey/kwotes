import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/utils.dart";

class StepChip extends StatelessWidget {
  const StepChip({
    super.key,
    required this.currentStep,
    this.isDark = false,
  });

  /// Use dark mode if true.
  final bool isDark;

  /// Current step we're on.
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: const StadiumBorder(
        side: BorderSide(color: Colors.transparent),
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      padding: const EdgeInsets.all(6.0),
      labelStyle: Utils.calligraphy.body(
        textStyle: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      label: Text(
        "step.progress".tr(
          namedArgs: {
            "current": currentStep.toString(),
            "total": "2",
          },
        ),
      ),
      // label: const Text("Step 1/2"),
    );
  }
}
