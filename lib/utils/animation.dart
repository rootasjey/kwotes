import 'package:flutter/material.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:simple_animations/simple_animations.dart';

/// Create a widget animating a quote's name.
/// Decides which animation is most suited for the quote.
Widget createHeroQuoteAnimation({Quote quote, double screenWidth}) {
  final quoteName = quote.name;

  if (quoteName.contains(',')) {
    return createPunctuationAnimation(
      quote: quote,
      punctuation: ', ',
      screenWidth: screenWidth,
    );
  }

  if (quoteName.contains('. ')) {
    return createPunctuationAnimation(
      quote: quote,
      punctuation: '. ',
      screenWidth: screenWidth,
    );
  }

  if (quoteName.contains('; ')) {
    return createPunctuationAnimation(
      quote: quote,
      punctuation: '; ',
      screenWidth: screenWidth,
    );
  }

  if (quoteName.length > 90) {
    return createLengthAnimation(
      quote: quote,
      screenWidth: screenWidth,
    );
  }

  return ControlledAnimation(
    duration: Duration(seconds: 1),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, value) {
      return Opacity(
        opacity: value,
        child: Text(
          quote.name,
          style: TextStyle(
            fontSize: FontSize.hero(quote.name) / dividerNumber(screenWidth),
          ),
        ),
      );
    },
  );
}

double dividerNumber(double screenWidth) {
  return 1352 / screenWidth;
}

/// Create animations according to the quote's punctuation.
Widget createPunctuationAnimation({
  Quote quote,
  String punctuation,
  double screenWidth,
}) {

  final quoteName = quote.name;

  final indexes = <int>[];
  bool hasNext = true;

  while (hasNext) {
    final index = quoteName.indexOf(punctuation);

    if (indexes.contains(index)) {
      hasNext = false;

    } else {
      indexes.add(index);
    }
  }

  int delayFactor = 0;

  final children = quoteName
    .split(' ')
    .map((word) {
      word += ' ';

      if (word.endsWith(punctuation)) {
        delayFactor++;
      }

      return FadeInY(
        endY: 0.0,
        beginY: 50.0,
        delay: delayFactor * 3.0,
        child: Text(word,
          style: TextStyle(
            fontSize: FontSize.hero(quote.name) / dividerNumber(screenWidth),
          ),
        ),
      );
    });

  return Wrap(
    children: <Widget>[
      ...children,
    ],
  );
}

/// Create animations according to the quote's length.
Widget createLengthAnimation({Quote quote, double screenWidth}) {
  final quoteName = quote.name;

  final half = quoteName.length ~/ 2;
  final rightHalf = quoteName.indexOf(' ', half);

  int index = 0;
  int delayFactor = 0;

  final children = quoteName
    .split(' ')
    .map((word) {
      word += ' ';

      if (rightHalf > index) {
        delayFactor++;
      }

      index ++;

      return FadeInY(
        endY: 0.0,
        beginY: 50.0,
        delay: delayFactor * 3.0,
        child: Text(word,
          style: TextStyle(
            fontSize: FontSize.hero(quote.name) / dividerNumber(screenWidth),
          ),
        ),
      );
    });

  return Wrap(
    children: <Widget>[
      ...children,
    ],
  );
}
