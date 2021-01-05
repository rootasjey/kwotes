import 'dart:math';

import 'package:flutter/material.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/types/font_size.dart';
import 'package:figstyle/types/quote.dart';
import 'package:simple_animations/simple_animations.dart';

/// Create a widget animating a quote's name.
/// Decides which animation is most suited for the quote.
Widget createHeroQuoteAnimation({
  Quote quote,
  double screenWidth,
  double screenHeight,
  TextStyle style,
  bool isMobile = false,
}) {
  screenHeight = screenHeight ?? screenWidth;

  final quoteName = quote.name;
  final denominator = dividerNumber(
    isMobile: isMobile,
    screenWidth: screenWidth,
    screenHeight: screenHeight,
  );

  final fontSize = FontSize.hero(quote.name) / denominator;

  if (style == null) {
    style = TextStyle(
      fontSize: fontSize,
    );
  } else {
    style = style.merge(TextStyle(
      fontSize: fontSize,
    ));
  }

  if (quoteName.contains(',')) {
    return createPunctuationAnimation(
      style: style,
      quote: quote,
      punctuation: ', ',
      screenWidth: screenWidth,
    );
  }

  if (quoteName.contains('. ')) {
    return createPunctuationAnimation(
      style: style,
      quote: quote,
      punctuation: '. ',
      screenWidth: screenWidth,
    );
  }

  if (quoteName.contains('; ')) {
    return createPunctuationAnimation(
      style: style,
      quote: quote,
      punctuation: '; ',
      screenWidth: screenWidth,
    );
  }

  if (quoteName.length > 90) {
    return createLengthAnimation(
      style: style,
      quote: quote,
      screenWidth: screenWidth,
    );
  }

  return CustomAnimation(
    duration: Duration(seconds: 1),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, child, value) {
      return Opacity(opacity: value, child: child);
    },
    child: Text(
      quote.name,
      style: style,
    ),
  );
}

double dividerNumber({
  double screenWidth,
  double screenHeight,
  bool isMobile = false,
}) {
  if (isMobile) {
    return 800 / min(screenWidth, screenHeight);
  }

  return 1452 / screenWidth;
}

/// Create animations according to the quote's punctuation.
Widget createPunctuationAnimation({
  Quote quote,
  String punctuation,
  double screenWidth,
  TextStyle style,
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

  final children = quoteName.split(' ').map((word) {
    word += ' ';

    if (word.endsWith(punctuation)) {
      delayFactor++;
    }

    return FadeInY(
      endY: 0.0,
      beginY: 10.0,
      delay: Duration(milliseconds: delayFactor * 100),
      child: Text(
        word,
        style: style,
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
Widget createLengthAnimation(
    {Quote quote, double screenWidth, TextStyle style}) {
  final quoteName = quote.name;

  final half = quoteName.length ~/ 2;
  final rightHalf = quoteName.indexOf(' ', half);

  int index = 0;
  int delayFactor = 0;

  final children = quoteName.split(' ').map((word) {
    word += ' ';

    if (rightHalf > index) {
      delayFactor++;
    }

    index++;

    return FadeInY(
      endY: 0.0,
      beginY: 10.0,
      delay: Duration(milliseconds: delayFactor * 100),
      child: Text(
        word,
        style: style,
      ),
    );
  });

  return Wrap(
    children: <Widget>[
      ...children,
    ],
  );
}
