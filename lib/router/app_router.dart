import 'package:auto_route/annotations.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/screens/settings.dart';

export 'app_router.gr.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(
      page: Home,
      path: '/',
      // children: [
      //   AutoRoute(page: Settings, path: 'settings'),
      // ],
    ),
    // MaterialRoute(page: Home, initial: true),
    // MaterialRoute(page: About, path: '/about'),
    // MaterialRoute(page: Tos, path: '/tos'),
    MaterialRoute(page: Settings, path: '/settings'),
  ],
)
class $AppRouter {}
