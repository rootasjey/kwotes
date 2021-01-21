import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.dart';
import 'package:figstyle/state/user.dart';

class NoAuthGuard extends AutoRouteGuard {
  @override
  Future<bool> canNavigate(
    List<PageRouteInfo> pendingRoutes,
    StackRouter router,
  ) async {
    if (!stateUser.isUserConnected) {
      return true;
    }

    router.root.replace(HomeRoute());
    return false;
  }
}
