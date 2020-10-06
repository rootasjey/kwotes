import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';

import '../screens/admin_quotes.dart';
import '../screens/web/dashboard.dart';
import '../screens/web/home.dart';

void onLongPressNavBack(BuildContext context) {
  if (AddQuoteInputs.navigatedFromPath == 'dashboard') {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Dashboard()));
    return;
  } else if (AddQuoteInputs.navigatedFromPath == 'admintempquotes') {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AdminQuotes()));
    return;
  }

  Navigator.of(context).push(MaterialPageRoute(builder: (_) => Home()));
}
