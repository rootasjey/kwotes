import 'package:auto_route/auto_route.dart';
import 'package:fig_style/router/app_router.dart';
import 'package:fig_style/state/user.dart';

class AdminAuthGuard extends AutoRouteGuard {
  @override
  Future<bool> canNavigate(
    List<PageRouteInfo> pendingRoutes,
    StackRouter router,
  ) async {
    if (stateUser.isUserConnected && stateUser.canManageQuotes) {
      return true;
    }

    router.root.navigate(HomeRoute());
    return false;
  }
}
