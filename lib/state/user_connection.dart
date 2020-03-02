import 'package:mobx/mobx.dart';

final isUserConnected = Observable(false);

final setUserConnected = Action(() {
  isUserConnected.value = true;
});

final setUserDisconnected = Action(() {
  isUserConnected.value = false;
});
