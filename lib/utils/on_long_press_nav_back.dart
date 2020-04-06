import 'package:flutter/material.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';

void onLongPressNavBack(BuildContext context) {
  if (AddQuoteInputs.navigatedFromPath == 'dashboard') {
    FluroRouter.router.navigateTo(context, DashboardRoute);
    return;

  } else if (AddQuoteInputs.navigatedFromPath == 'admintempquotes') {
    FluroRouter.router.navigateTo(context, AdminTempQuotesRoute);
    return;
  }

  FluroRouter.router.navigateTo(context, RootRoute);
}
