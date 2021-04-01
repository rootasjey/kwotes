import 'package:fig_style/components/circle_button.dart';
import 'package:fig_style/state/colors.dart';
import 'package:flutter/material.dart';

class SheetHeader extends StatelessWidget {
  final String title;
  final String subTitle;

  SheetHeader({
    @required this.title,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleButton(
          onTap: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
            size: 20.0,
            color: stateColors.primary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (subTitle != null)
                Text(
                  subTitle,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
