import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/app_router.dart';
import 'package:figstyle/state/user.dart';

class AdminAuthGuard extends AutoRouteGuard {
  @override
  Future<bool> canNavigate(
    List<PageRouteInfo> pendingRoutes,
    StackRouter router,
  ) async {
    if (stateUser.isUserConnected && stateUser.canManageQuote) {
      return true;
    }

    router.root.navigate(HomeRoute());
    return false;
  }
}
