import "package:flutter/material.dart";

class SwipeFromRightContainer extends StatelessWidget {
  /// Container for swipe gesture (ideally from right).
  const SwipeFromRightContainer({
    super.key,
    required this.color,
    required this.iconData,
  });

  /// Color of the container.
  /// The container will be filled with gradien of this color.
  final Color color;

  /// Icon to display in the container.
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.0),
            color.withOpacity(0.0),
            color.withOpacity(0.0),
            color.withOpacity(0.0),
            color.withOpacity(0.1),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Icon(
              iconData,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
