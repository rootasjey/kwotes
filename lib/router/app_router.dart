import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:figstyle/router/admin_auth_guard.dart';
import 'package:figstyle/router/auth_guard.dart';
import 'package:figstyle/router/no_auth_guard.dart';
import 'package:figstyle/screens/about.dart';
import 'package:figstyle/screens/add_quote/steps.dart';
import 'package:figstyle/screens/admin_temp_quotes.dart';
import 'package:figstyle/screens/author_page.dart';
import 'package:figstyle/screens/authors.dart';
import 'package:figstyle/screens/changelog.dart';
import 'package:figstyle/screens/contact.dart';
import 'package:figstyle/screens/dashboard_page.dart';
import 'package:figstyle/screens/delete_account.dart';
import 'package:figstyle/screens/drafts.dart';
import 'package:figstyle/screens/edit_author.dart';
import 'package:figstyle/screens/favourites.dart';
import 'package:figstyle/screens/forgot_password.dart';
import 'package:figstyle/screens/home/home.dart';
import 'package:figstyle/screens/my_published_quotes.dart';
import 'package:figstyle/screens/my_temp_quotes.dart';
import 'package:figstyle/screens/on_boarding.dart';
import 'package:figstyle/screens/quote_page.dart';
import 'package:figstyle/screens/quotes_list.dart';
import 'package:figstyle/screens/quotes_lists.dart';
import 'package:figstyle/screens/quotidians.dart';
import 'package:figstyle/screens/random_quotes.dart';
import 'package:figstyle/screens/recent_quotes.dart';
import 'package:figstyle/screens/reference_page.dart';
import 'package:figstyle/screens/references.dart';
import 'package:figstyle/screens/search.dart';
import 'package:figstyle/screens/settings.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/screens/signup.dart';
import 'package:figstyle/screens/topic_page.dart';
import 'package:figstyle/screens/tos.dart';
import 'package:figstyle/screens/undefined_page.dart';
import 'package:figstyle/screens/update_email.dart';
import 'package:figstyle/screens/update_password.dart';
import 'package:figstyle/screens/update_username.dart';

export 'app_router.gr.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(path: '/', page: Home),
    MaterialRoute(path: '/about', page: About),
    AutoRoute(
      path: '/authors',
      page: EmptyRouterPage,
      name: 'AuthorsDeepRoute',
      children: [
        MaterialRoute(path: '', page: Authors),
        MaterialRoute(path: ':authorId', page: AuthorPage),
      ],
    ),
    MaterialRoute(path: '/changelog', page: Changelog),
    MaterialRoute(path: '/contact', page: Contact),
    AutoRoute(
      path: '/quotes',
      page: EmptyRouterPage,
      name: 'QuotesDeepRoute',
      children: [
        RedirectRoute(path: '', redirectTo: 'recent'),
        AutoRoute(path: 'recent', page: RecentQuotes),
        AutoRoute(path: 'random', page: RandomQuotes),
        MaterialRoute(path: ':quoteId', page: QuotePage),
      ],
    ),
    AutoRoute(
      path: '/dashboard',
      page: DashboardPage,
      guards: [AuthGuard],
      children: [
        RedirectRoute(path: '', redirectTo: 'fav'),
        AutoRoute(path: 'addquote', page: AddQuoteSteps),
        AutoRoute(
          path: 'admin',
          page: EmptyRouterPage,
          name: 'AdminDeepRoute',
          guards: [AdminAuthGuard],
          children: [
            RedirectRoute(path: '', redirectTo: 'temp'),
            AutoRoute(
              path: 'edit',
              page: EmptyRouterPage,
              name: 'AdminEditDeepRoute',
              children: [
                AutoRoute(path: 'author/:authorId', page: EditAuthor),
              ],
            ),
            MaterialRoute(path: 'quotidians', page: Quotidians),
            AutoRoute(
              path: 'temp',
              page: EmptyRouterPage,
              name: 'AdminTempDeepRoute',
              children: [
                AutoRoute(path: 'quotes', page: AdminTempQuotes),
              ],
            ),
          ],
        ),
        AutoRoute(path: 'drafts', page: Drafts),
        AutoRoute(path: 'fav', page: Favourites),
        AutoRoute(
          path: 'lists',
          page: EmptyRouterPage,
          name: 'QuotesListsDeepRoute',
          children: [
            AutoRoute(path: '', page: QuotesLists),
            AutoRoute(path: ':listId', page: QuotesList),
          ],
        ),
        AutoRoute(path: 'published', page: MyPublishedQuotes),
        AutoRoute(path: 'temp', page: MyTempQuotes),
        AutoRoute(
          path: 'settings',
          page: EmptyRouterPage,
          name: 'DashboardSettingsDeepRoute',
          children: [
            MaterialRoute(
              path: '',
              page: Settings,
              name: 'DashboardSettingsRoute',
            ),
            AutoRoute(path: 'delete/account', page: DeleteAccount),
            AutoRoute(
              path: 'update',
              page: EmptyRouterPage,
              name: 'AccountUpdateDeepRoute',
              children: [
                MaterialRoute(path: 'email', page: UpdateEmail),
                MaterialRoute(path: 'password', page: UpdatePassword),
                MaterialRoute(path: 'username', page: UpdateUsername),
              ],
            ),
          ],
        ),
      ],
    ),
    MaterialRoute(path: '/onboarding', page: OnBoarding),
    AutoRoute(
      path: '/topics',
      page: EmptyRouterPage,
      name: 'TopicsDeepRoute',
      children: [
        MaterialRoute(path: ':topicName', page: TopicPage),
      ],
    ),
    MaterialRoute(path: '/forgotpassword', page: ForgotPassword),
    AutoRoute(
      path: '/references',
      page: EmptyRouterPage,
      name: 'ReferencesDeepRoute',
      children: [
        MaterialRoute(path: '', page: References),
        MaterialRoute(path: ':referenceId', page: ReferencePage),
      ],
    ),
    MaterialRoute(path: '/settings', page: Settings),
    MaterialRoute(path: '/search', page: Search),
    MaterialRoute(path: '/signin', page: Signin, guards: [NoAuthGuard]),
    MaterialRoute(path: '/signup', page: Signup, guards: [NoAuthGuard]),
    MaterialRoute(
      path: '/signout',
      page: EmptyRouterPage,
      name: 'SignOutRoute',
    ),
    AutoRoute(
      path: '/ext',
      page: EmptyRouterPage,
      name: 'ExtDeepRoute',
      children: [
        MaterialRoute(
          path: 'github',
          page: EmptyRouterPage,
          name: 'GitHubRoute',
        ),
        MaterialRoute(
          path: 'android',
          page: EmptyRouterPage,
          name: 'AndroidAppRoute',
        ),
        MaterialRoute(
          path: 'ios',
          page: EmptyRouterPage,
          name: 'IosAppRoute',
        ),
      ],
    ),
    MaterialRoute(path: '/tos', page: Tos),
    MaterialRoute(path: '*', page: UndefinedPage),
  ],
)
class $AppRouter {}
