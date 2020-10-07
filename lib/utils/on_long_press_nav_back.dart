import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/screens/recent_quotes.dart';
import 'package:memorare/screens/home/home.dart';
import 'package:memorare/screens/web/dashboard.dart';

void onLongPressNavBack(BuildContext context) {
  if (AddQuoteInputs.navigatedFromPath == 'dashboard') {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Dashboard()));
    return;
  } else if (AddQuoteInputs.navigatedFromPath == 'admintempquotes') {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RecentQuotes()));
    return;
  }

  Navigator.of(context).push(MaterialPageRoute(builder: (_) => Home()));
}
