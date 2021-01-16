import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:figstyle/screens/about.dart';
import 'package:figstyle/screens/forgot_password.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/screens/search.dart';
import 'package:figstyle/screens/settings.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/screens/signup.dart';
import 'package:figstyle/screens/tos.dart';

export 'app_router.gr.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(path: '/', page: Home),
    MaterialRoute(path: '/about', page: About),
    // AutoRoute(
    //   path: 'admin',
    //   page: EmptyRouterPage,
    //   name: 'AdminDeepRoute',
    //   children: [
    //     RedirectRoute(path: '', redirectTo: 'temp'),
    //     AutoRoute(path: 'temp', page: AdminTempQuotes),
    //     AutoRoute(path: 'quotidians', page: Quotidians),
    //   ],
    // ),
    // AutoRoute(
    //   path: 'authors',
    //   page: Authors,
    //   children: [
    //     AutoRoute(path: '/:id', page: AuthorPage),
    //   ],
    // ),
    // AutoRoute(
    //   path: 'quotes',
    //   page: EmptyRouterPage,
    //   name: 'QuotesDeepRoute',
    //   children: [
    //     RedirectRoute(path: '', redirectTo: 'recent'),
    //     AutoRoute(path: 'recent', page: RecentQuotes),
    //   ],
    // ),
    // AutoRoute(
    //   path: 'account',
    //   page: EmptyRouterPage,
    //   name: 'AccountDeepRoute',
    //   children: [
    //     RedirectRoute(path: '', redirectTo: 'settings'),
    //     AutoRoute(path: 'settings', page: Settings),
    //     AutoRoute(path: 'addquote', page: AddQuoteSteps),
    //     AutoRoute(path: 'drafts', page: Drafts),
    //     AutoRoute(path: 'fav', page: Favourites),
    //     AutoRoute(path: 'lists', page: QuotesLists),
    //     AutoRoute(path: 'published', page: MyPublishedQuotes),
    //     AutoRoute(path: 'temp', page: MyTempQuotes),
    //   ],
    // ),
    // AutoRoute(
    //   path: 'topics',
    //   page: EmptyRouterPage,
    //   name: 'TopicsDeepRoute',
    //   children: [
    //     RedirectRoute(path: '', redirectTo: 'all'),
    //     AutoRoute(path: 'all', page: TopicPage),
    //   ],
    // ),
    MaterialRoute(path: '/forgotpassword', page: ForgotPassword),
    MaterialRoute(path: '/settings', page: Settings),
    MaterialRoute(path: '/search', page: Search),
    MaterialRoute(path: '/signin', page: Signin),
    MaterialRoute(path: '/signup', page: Signup),
    MaterialRoute(path: '/tos', page: Tos),
  ],
)
class $AppRouter {}
