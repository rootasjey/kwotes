// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import '../screens/home/home.dart' as _i2;
import '../screens/settings.dart' as _i3;

class AppRouter extends _i1.RootStackRouter {
  AppRouter();

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    HomeRoute.name: (entry) {
      var route = entry.routeData.as<HomeRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i2.Home(mobileInitialIndex: route.mobileInitialIndex ?? 0));
    },
    SettingsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i3.Settings());
    }
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig<HomeRoute>(HomeRoute.name,
            path: '/', routeBuilder: (match) => HomeRoute.fromMatch(match)),
        _i1.RouteConfig<SettingsRoute>(SettingsRoute.name,
            path: '/settings',
            routeBuilder: (match) => SettingsRoute.fromMatch(match))
      ];
}

class HomeRoute extends _i1.PageRouteInfo {
  HomeRoute({this.mobileInitialIndex = 0}) : super(name, path: '/');

  HomeRoute.fromMatch(_i1.RouteMatch match)
      : mobileInitialIndex = null,
        super.fromMatch(match);

  final int mobileInitialIndex;

  static const String name = 'HomeRoute';
}

class SettingsRoute extends _i1.PageRouteInfo {
  const SettingsRoute() : super(name, path: '/settings');

  SettingsRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'SettingsRoute';
}
