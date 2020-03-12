import 'package:flutter/material.dart';
import 'package:memorare/types/font_size.dart';
import 'package:memorare/types/quote.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

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
  List<String> parts = quoteName.split(punctuation);

  int index = 0;

  final children = parts.map((part) {
    index++;

    if (index < parts.length) { part += punctuation; }

    return ControlledAnimation(
      delay: Duration(milliseconds: index * 500),
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value) {
        return Opacity(
          opacity: value,
          child: Text(part,
            style: TextStyle(
              fontSize: FontSize.hero(quote.name) / dividerNumber(screenWidth),
            ),
          ),
        );
      },
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

  List<String> parts = [
    quoteName.substring(0, rightHalf),
    quoteName.substring(rightHalf + 1, quoteName.length),
  ];

  int index = 0;

  final children = parts.map((part) {
    index++;

    if (index < parts.length) { part += ' '; }

    return ControlledAnimation(
      delay: Duration(milliseconds: index * 500),
      duration: 1.seconds,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value) {
        return Opacity(
          opacity: value,
          child: Text(part,
            style: TextStyle(
              fontSize: FontSize.hero(quote.name) / dividerNumber(screenWidth),
            ),
          ),
        );
      },
    );
  });

  return Wrap(
    children: <Widget>[
      ...children,
    ],
  );
}
