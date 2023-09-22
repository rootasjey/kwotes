import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";

/// In validation quotes page header.
class InValidationPageHeader extends StatelessWidget {
  const InValidationPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 48.0, bottom: 42.0),
        child: Hero(
          tag: "in_validation",
          child: Material(
            color: Colors.transparent,
            child: Text.rich(
              TextSpan(text: "in_validation.name".tr(), children: [
                TextSpan(
                  text: ".",
                  style: TextStyle(
                    color: Constants.colors.inValidation,
                  ),
                ),
              ]),
              style: Utils.calligraphy.title(
                textStyle: TextStyle(
                  fontSize: 74.0,
                  fontWeight: FontWeight.w200,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
