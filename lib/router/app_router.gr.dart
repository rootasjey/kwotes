// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;
import 'auth_guard.dart' as _i3;
import 'no_auth_guard.dart' as _i4;
import 'admin_auth_guard.dart' as _i5;
import '../screens/home/home.dart' as _i6;
import '../screens/about.dart' as _i7;
import '../screens/changelog.dart' as _i8;
import '../screens/contact.dart' as _i9;
import '../screens/dashboard_page.dart' as _i10;
import '../screens/on_boarding.dart' as _i11;
import '../screens/forgot_password.dart' as _i12;
import '../screens/settings.dart' as _i13;
import '../screens/search.dart' as _i14;
import '../screens/signin.dart' as _i15;
import '../screens/signup.dart' as _i16;
import '../screens/tos.dart' as _i17;
import '../screens/undefined_page.dart' as _i18;
import '../screens/authors.dart' as _i19;
import '../screens/author_page.dart' as _i20;
import '../screens/recent_quotes.dart' as _i21;
import '../screens/random_quotes.dart' as _i22;
import '../screens/quote_page.dart' as _i23;
import '../screens/add_quote/steps.dart' as _i24;
import '../screens/drafts.dart' as _i25;
import '../screens/favourites.dart' as _i26;
import '../screens/my_published_quotes.dart' as _i27;
import '../screens/my_temp_quotes.dart' as _i28;
import '../screens/quotidians.dart' as _i29;
import '../screens/admin_temp_quotes.dart' as _i30;
import '../screens/quotes_lists.dart' as _i31;
import '../screens/quotes_list.dart' as _i32;
import '../screens/delete_account.dart' as _i33;
import '../screens/update_email.dart' as _i34;
import '../screens/update_password.dart' as _i35;
import '../screens/update_username.dart' as _i36;
import '../screens/topic_page.dart' as _i37;
import '../screens/references.dart' as _i38;
import '../screens/reference_page.dart' as _i39;
import 'package:flutter/foundation.dart' as _i40;
import '../types/quote.dart' as _i41;

class AppRouter extends _i1.RootStackRouter {
  AppRouter(
      {@_i2.required this.authGuard,
      @_i2.required this.noAuthGuard,
      @_i2.required this.adminAuthGuard})
      : assert(authGuard != null),
        assert(noAuthGuard != null),
        assert(adminAuthGuard != null);

  final _i3.AuthGuard authGuard;

  final _i4.NoAuthGuard noAuthGuard;

  final _i5.AdminAuthGuard adminAuthGuard;

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    HomeRoute.name: (entry) {
      var route = entry.routeData.as<HomeRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i6.Home(mobileInitialIndex: route.mobileInitialIndex ?? 0));
    },
    AboutRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i7.About());
    },
    AuthorsDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    ChangelogRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i8.Changelog());
    },
    ContactRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i9.Contact());
    },
    QuotesDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    DashboardPageRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i10.DashboardPage());
    },
    OnBoardingRoute.name: (entry) {
      var route = entry.routeData.as<OnBoardingRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i11.OnBoarding(isDesktop: route.isDesktop ?? false));
    },
    TopicsDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    ForgotPasswordRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i12.ForgotPassword());
    },
    ReferencesDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    SettingsRoute.name: (entry) {
      var route = entry.routeData.as<SettingsRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i13.Settings(
              key: route.key, showAppBar: route.showAppBar ?? true));
    },
    SearchRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i14.Search());
    },
    SigninRoute.name: (entry) {
      var route = entry.routeData.as<SigninRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i15.Signin(
              key: route.key, onSigninResult: route.onSigninResult));
    },
    SignupRoute.name: (entry) {
      var route = entry.routeData.as<SignupRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i16.Signup(
              key: route.key, onSignupResult: route.onSignupResult));
    },
    SignOutRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    ExtDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    TosRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i17.Tos());
    },
    UndefinedPageRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i18.UndefinedPage());
    },
    AuthorsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i19.Authors());
    },
    AuthorPageRoute.name: (entry) {
      var route = entry.routeData.as<AuthorPageRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i20.AuthorPage(
              authorId: route.authorId,
              authorImageUrl: route.authorImageUrl ?? '',
              authorName: route.authorName ?? ''));
    },
    RecentQuotesRoute.name: (entry) {
      var route = entry.routeData.as<RecentQuotesRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i21.RecentQuotes(
              showNavBackIcon: route.showNavBackIcon ?? true));
    },
    RandomQuotesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i22.RandomQuotes());
    },
    QuotePageRoute.name: (entry) {
      var route = entry.routeData.as<QuotePageRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i23.QuotePage(quoteId: route.quoteId, quote: route.quote));
    },
    AddQuoteStepsRoute.name: (entry) {
      var route = entry.routeData.as<AddQuoteStepsRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i24.AddQuoteSteps(key: route.key, step: route.step ?? 0));
    },
    AdminDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    DraftsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i25.Drafts());
    },
    FavouritesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i26.Favourites());
    },
    QuotesListsDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    MyPublishedQuotesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i27.MyPublishedQuotes());
    },
    MyTempQuotesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i28.MyTempQuotes());
    },
    DashboardSettingsDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    QuotidiansRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i29.Quotidians());
    },
    AdminTempDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    AdminTempQuotesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i30.AdminTempQuotes());
    },
    QuotesListsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i31.QuotesLists());
    },
    QuotesListRoute.name: (entry) {
      var route = entry.routeData.as<QuotesListRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child:
              _i32.QuotesList(listId: route.listId, onResult: route.onResult));
    },
    DashboardSettingsRoute.name: (entry) {
      var route = entry.routeData.as<DashboardSettingsRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i13.Settings(
              key: route.key, showAppBar: route.showAppBar ?? true));
    },
    DeleteAccountRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i33.DeleteAccount());
    },
    AccountUpdateDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    UpdateEmailRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i34.UpdateEmail());
    },
    UpdatePasswordRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i35.UpdatePassword());
    },
    UpdateUsernameRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i36.UpdateUsername());
    },
    TopicPageRoute.name: (entry) {
      var route = entry.routeData.as<TopicPageRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i37.TopicPage(
              topicName: route.topicName ?? '', decimal: route.decimal));
    },
    ReferencesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i38.References());
    },
    ReferencePageRoute.name: (entry) {
      var route = entry.routeData.as<ReferencePageRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i39.ReferencePage(
              referenceId: route.referenceId,
              referenceName: route.referenceName,
              referenceImageUrl: route.referenceImageUrl));
    },
    GitHubRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    AndroidAppRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    IosAppRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    }
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig<HomeRoute>(HomeRoute.name,
            path: '/', routeBuilder: (match) => HomeRoute.fromMatch(match)),
        _i1.RouteConfig<AboutRoute>(AboutRoute.name,
            path: '/about',
            routeBuilder: (match) => AboutRoute.fromMatch(match)),
        _i1.RouteConfig<AuthorsDeepRoute>(AuthorsDeepRoute.name,
            path: '/authors',
            routeBuilder: (match) => AuthorsDeepRoute.fromMatch(match),
            children: [
              _i1.RouteConfig<AuthorsRoute>(AuthorsRoute.name,
                  path: '',
                  routeBuilder: (match) => AuthorsRoute.fromMatch(match)),
              _i1.RouteConfig<AuthorPageRoute>(AuthorPageRoute.name,
                  path: ':authorId',
                  routeBuilder: (match) => AuthorPageRoute.fromMatch(match))
            ]),
        _i1.RouteConfig<ChangelogRoute>(ChangelogRoute.name,
            path: '/changelog',
            routeBuilder: (match) => ChangelogRoute.fromMatch(match)),
        _i1.RouteConfig<ContactRoute>(ContactRoute.name,
            path: '/contact',
            routeBuilder: (match) => ContactRoute.fromMatch(match)),
        _i1.RouteConfig<QuotesDeepRoute>(QuotesDeepRoute.name,
            path: '/quotes',
            routeBuilder: (match) => QuotesDeepRoute.fromMatch(match),
            children: [
              _i1.RouteConfig('#redirect',
                  path: '', redirectTo: 'recent', fullMatch: true),
              _i1.RouteConfig<RecentQuotesRoute>(RecentQuotesRoute.name,
                  path: 'recent',
                  routeBuilder: (match) => RecentQuotesRoute.fromMatch(match)),
              _i1.RouteConfig<RandomQuotesRoute>(RandomQuotesRoute.name,
                  path: 'random',
                  routeBuilder: (match) => RandomQuotesRoute.fromMatch(match)),
              _i1.RouteConfig<QuotePageRoute>(QuotePageRoute.name,
                  path: ':quoteId',
                  routeBuilder: (match) => QuotePageRoute.fromMatch(match))
            ]),
        _i1.RouteConfig<DashboardPageRoute>(DashboardPageRoute.name,
            path: '/dashboard',
            routeBuilder: (match) => DashboardPageRoute.fromMatch(match),
            guards: [
              authGuard
            ],
            children: [
              _i1.RouteConfig('#redirect',
                  path: '', redirectTo: 'fav', fullMatch: true),
              _i1.RouteConfig<AddQuoteStepsRoute>(AddQuoteStepsRoute.name,
                  path: 'addquote',
                  routeBuilder: (match) => AddQuoteStepsRoute.fromMatch(match)),
              _i1.RouteConfig<AdminDeepRoute>(AdminDeepRoute.name,
                  path: 'admin',
                  routeBuilder: (match) => AdminDeepRoute.fromMatch(match),
                  guards: [
                    adminAuthGuard
                  ],
                  children: [
                    _i1.RouteConfig('#redirect',
                        path: '', redirectTo: 'temp', fullMatch: true),
                    _i1.RouteConfig<QuotidiansRoute>(QuotidiansRoute.name,
                        path: 'quotidians',
                        routeBuilder: (match) =>
                            QuotidiansRoute.fromMatch(match)),
                    _i1.RouteConfig<AdminTempDeepRoute>(AdminTempDeepRoute.name,
                        path: 'temp',
                        routeBuilder: (match) =>
                            AdminTempDeepRoute.fromMatch(match),
                        children: [
                          _i1.RouteConfig<AdminTempQuotesRoute>(
                              AdminTempQuotesRoute.name,
                              path: 'quotes',
                              routeBuilder: (match) =>
                                  AdminTempQuotesRoute.fromMatch(match))
                        ])
                  ]),
              _i1.RouteConfig<DraftsRoute>(DraftsRoute.name,
                  path: 'drafts',
                  routeBuilder: (match) => DraftsRoute.fromMatch(match)),
              _i1.RouteConfig<FavouritesRoute>(FavouritesRoute.name,
                  path: 'fav',
                  routeBuilder: (match) => FavouritesRoute.fromMatch(match)),
              _i1.RouteConfig<QuotesListsDeepRoute>(QuotesListsDeepRoute.name,
                  path: 'lists',
                  routeBuilder: (match) =>
                      QuotesListsDeepRoute.fromMatch(match),
                  children: [
                    _i1.RouteConfig<QuotesListsRoute>(QuotesListsRoute.name,
                        path: '',
                        routeBuilder: (match) =>
                            QuotesListsRoute.fromMatch(match)),
                    _i1.RouteConfig<QuotesListRoute>(QuotesListRoute.name,
                        path: ':listId',
                        routeBuilder: (match) =>
                            QuotesListRoute.fromMatch(match))
                  ]),
              _i1.RouteConfig<MyPublishedQuotesRoute>(
                  MyPublishedQuotesRoute.name,
                  path: 'published',
                  routeBuilder: (match) =>
                      MyPublishedQuotesRoute.fromMatch(match)),
              _i1.RouteConfig<MyTempQuotesRoute>(MyTempQuotesRoute.name,
                  path: 'temp',
                  routeBuilder: (match) => MyTempQuotesRoute.fromMatch(match)),
              _i1.RouteConfig<DashboardSettingsDeepRoute>(
                  DashboardSettingsDeepRoute.name,
                  path: 'settings',
                  routeBuilder: (match) =>
                      DashboardSettingsDeepRoute.fromMatch(match),
                  children: [
                    _i1.RouteConfig<DashboardSettingsRoute>(
                        DashboardSettingsRoute.name,
                        path: '',
                        routeBuilder: (match) =>
                            DashboardSettingsRoute.fromMatch(match)),
                    _i1.RouteConfig<DeleteAccountRoute>(DeleteAccountRoute.name,
                        path: 'delete/account',
                        routeBuilder: (match) =>
                            DeleteAccountRoute.fromMatch(match)),
                    _i1.RouteConfig<AccountUpdateDeepRoute>(
                        AccountUpdateDeepRoute.name,
                        path: 'update',
                        routeBuilder: (match) =>
                            AccountUpdateDeepRoute.fromMatch(match),
                        children: [
                          _i1.RouteConfig<UpdateEmailRoute>(
                              UpdateEmailRoute.name,
                              path: 'email',
                              routeBuilder: (match) =>
                                  UpdateEmailRoute.fromMatch(match)),
                          _i1.RouteConfig<UpdatePasswordRoute>(
                              UpdatePasswordRoute.name,
                              path: 'password',
                              routeBuilder: (match) =>
                                  UpdatePasswordRoute.fromMatch(match)),
                          _i1.RouteConfig<UpdateUsernameRoute>(
                              UpdateUsernameRoute.name,
                              path: 'username',
                              routeBuilder: (match) =>
                                  UpdateUsernameRoute.fromMatch(match))
                        ])
                  ])
            ]),
        _i1.RouteConfig<OnBoardingRoute>(OnBoardingRoute.name,
            path: '/onboarding',
            routeBuilder: (match) => OnBoardingRoute.fromMatch(match)),
        _i1.RouteConfig<TopicsDeepRoute>(TopicsDeepRoute.name,
            path: '/topics',
            routeBuilder: (match) => TopicsDeepRoute.fromMatch(match),
            children: [
              _i1.RouteConfig<TopicPageRoute>(TopicPageRoute.name,
                  path: ':topicName',
                  routeBuilder: (match) => TopicPageRoute.fromMatch(match))
            ]),
        _i1.RouteConfig<ForgotPasswordRoute>(ForgotPasswordRoute.name,
            path: '/forgotpassword',
            routeBuilder: (match) => ForgotPasswordRoute.fromMatch(match)),
        _i1.RouteConfig<ReferencesDeepRoute>(ReferencesDeepRoute.name,
            path: '/references',
            routeBuilder: (match) => ReferencesDeepRoute.fromMatch(match),
            children: [
              _i1.RouteConfig<ReferencesRoute>(ReferencesRoute.name,
                  path: '',
                  routeBuilder: (match) => ReferencesRoute.fromMatch(match)),
              _i1.RouteConfig<ReferencePageRoute>(ReferencePageRoute.name,
                  path: ':referenceId',
                  routeBuilder: (match) => ReferencePageRoute.fromMatch(match))
            ]),
        _i1.RouteConfig<SettingsRoute>(SettingsRoute.name,
            path: '/settings',
            routeBuilder: (match) => SettingsRoute.fromMatch(match)),
        _i1.RouteConfig<SearchRoute>(SearchRoute.name,
            path: '/search',
            routeBuilder: (match) => SearchRoute.fromMatch(match)),
        _i1.RouteConfig<SigninRoute>(SigninRoute.name,
            path: '/signin',
            routeBuilder: (match) => SigninRoute.fromMatch(match),
            guards: [noAuthGuard]),
        _i1.RouteConfig<SignupRoute>(SignupRoute.name,
            path: '/signup',
            routeBuilder: (match) => SignupRoute.fromMatch(match),
            guards: [noAuthGuard]),
        _i1.RouteConfig<SignOutRoute>(SignOutRoute.name,
            path: '/signout',
            routeBuilder: (match) => SignOutRoute.fromMatch(match)),
        _i1.RouteConfig<ExtDeepRoute>(ExtDeepRoute.name,
            path: '/ext',
            routeBuilder: (match) => ExtDeepRoute.fromMatch(match),
            children: [
              _i1.RouteConfig<GitHubRoute>(GitHubRoute.name,
                  path: 'github',
                  routeBuilder: (match) => GitHubRoute.fromMatch(match)),
              _i1.RouteConfig<AndroidAppRoute>(AndroidAppRoute.name,
                  path: 'android',
                  routeBuilder: (match) => AndroidAppRoute.fromMatch(match)),
              _i1.RouteConfig<IosAppRoute>(IosAppRoute.name,
                  path: 'ios',
                  routeBuilder: (match) => IosAppRoute.fromMatch(match))
            ]),
        _i1.RouteConfig<TosRoute>(TosRoute.name,
            path: '/tos', routeBuilder: (match) => TosRoute.fromMatch(match)),
        _i1.RouteConfig<UndefinedPageRoute>(UndefinedPageRoute.name,
            path: '*',
            routeBuilder: (match) => UndefinedPageRoute.fromMatch(match))
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

class AboutRoute extends _i1.PageRouteInfo {
  const AboutRoute() : super(name, path: '/about');

  AboutRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AboutRoute';
}

class AuthorsDeepRoute extends _i1.PageRouteInfo {
  const AuthorsDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/authors', initialChildren: children);

  AuthorsDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AuthorsDeepRoute';
}

class ChangelogRoute extends _i1.PageRouteInfo {
  const ChangelogRoute() : super(name, path: '/changelog');

  ChangelogRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ChangelogRoute';
}

class ContactRoute extends _i1.PageRouteInfo {
  const ContactRoute() : super(name, path: '/contact');

  ContactRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ContactRoute';
}

class QuotesDeepRoute extends _i1.PageRouteInfo {
  const QuotesDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/quotes', initialChildren: children);

  QuotesDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'QuotesDeepRoute';
}

class DashboardPageRoute extends _i1.PageRouteInfo {
  const DashboardPageRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/dashboard', initialChildren: children);

  DashboardPageRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'DashboardPageRoute';
}

class OnBoardingRoute extends _i1.PageRouteInfo {
  OnBoardingRoute({this.isDesktop = false}) : super(name, path: '/onboarding');

  OnBoardingRoute.fromMatch(_i1.RouteMatch match)
      : isDesktop = null,
        super.fromMatch(match);

  final bool isDesktop;

  static const String name = 'OnBoardingRoute';
}

class TopicsDeepRoute extends _i1.PageRouteInfo {
  const TopicsDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/topics', initialChildren: children);

  TopicsDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'TopicsDeepRoute';
}

class ForgotPasswordRoute extends _i1.PageRouteInfo {
  const ForgotPasswordRoute() : super(name, path: '/forgotpassword');

  ForgotPasswordRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ForgotPasswordRoute';
}

class ReferencesDeepRoute extends _i1.PageRouteInfo {
  const ReferencesDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/references', initialChildren: children);

  ReferencesDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ReferencesDeepRoute';
}

class SettingsRoute extends _i1.PageRouteInfo {
  SettingsRoute({this.key, this.showAppBar = true})
      : super(name, path: '/settings');

  SettingsRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        showAppBar = match.pathParams.getBool('showAppBar'),
        super.fromMatch(match);

  final _i40.Key key;

  final bool showAppBar;

  static const String name = 'SettingsRoute';
}

class SearchRoute extends _i1.PageRouteInfo {
  const SearchRoute() : super(name, path: '/search');

  SearchRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'SearchRoute';
}

class SigninRoute extends _i1.PageRouteInfo {
  SigninRoute({this.key, this.onSigninResult}) : super(name, path: '/signin');

  SigninRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        onSigninResult = null,
        super.fromMatch(match);

  final _i40.Key key;

  final void Function(bool) onSigninResult;

  static const String name = 'SigninRoute';
}

class SignupRoute extends _i1.PageRouteInfo {
  SignupRoute({this.key, this.onSignupResult}) : super(name, path: '/signup');

  SignupRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        onSignupResult = null,
        super.fromMatch(match);

  final _i40.Key key;

  final void Function(bool) onSignupResult;

  static const String name = 'SignupRoute';
}

class SignOutRoute extends _i1.PageRouteInfo {
  const SignOutRoute() : super(name, path: '/signout');

  SignOutRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'SignOutRoute';
}

class ExtDeepRoute extends _i1.PageRouteInfo {
  const ExtDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/ext', initialChildren: children);

  ExtDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ExtDeepRoute';
}

class TosRoute extends _i1.PageRouteInfo {
  const TosRoute() : super(name, path: '/tos');

  TosRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'TosRoute';
}

class UndefinedPageRoute extends _i1.PageRouteInfo {
  const UndefinedPageRoute() : super(name, path: '*');

  UndefinedPageRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'UndefinedPageRoute';
}

class AuthorsRoute extends _i1.PageRouteInfo {
  const AuthorsRoute() : super(name, path: '');

  AuthorsRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AuthorsRoute';
}

class AuthorPageRoute extends _i1.PageRouteInfo {
  AuthorPageRoute(
      {this.authorId, this.authorImageUrl = '', this.authorName = ''})
      : super(name, path: ':authorId', params: {'authorId': authorId});

  AuthorPageRoute.fromMatch(_i1.RouteMatch match)
      : authorId = match.pathParams.getString('authorId'),
        authorImageUrl = null,
        authorName = null,
        super.fromMatch(match);

  final String authorId;

  final String authorImageUrl;

  final String authorName;

  static const String name = 'AuthorPageRoute';
}

class RecentQuotesRoute extends _i1.PageRouteInfo {
  RecentQuotesRoute({this.showNavBackIcon = true})
      : super(name, path: 'recent');

  RecentQuotesRoute.fromMatch(_i1.RouteMatch match)
      : showNavBackIcon = null,
        super.fromMatch(match);

  final bool showNavBackIcon;

  static const String name = 'RecentQuotesRoute';
}

class RandomQuotesRoute extends _i1.PageRouteInfo {
  const RandomQuotesRoute() : super(name, path: 'random');

  RandomQuotesRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'RandomQuotesRoute';
}

class QuotePageRoute extends _i1.PageRouteInfo {
  QuotePageRoute({this.quoteId, this.quote})
      : super(name, path: ':quoteId', params: {'quoteId': quoteId});

  QuotePageRoute.fromMatch(_i1.RouteMatch match)
      : quoteId = match.pathParams.getString('quoteId'),
        quote = null,
        super.fromMatch(match);

  final String quoteId;

  final _i41.Quote quote;

  static const String name = 'QuotePageRoute';
}

class AddQuoteStepsRoute extends _i1.PageRouteInfo {
  AddQuoteStepsRoute({this.key, this.step = 0})
      : super(name, path: 'addquote', queryParams: {'step': step});

  AddQuoteStepsRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        step = match.queryParams.getInt('step', 0),
        super.fromMatch(match);

  final _i40.Key key;

  final int step;

  static const String name = 'AddQuoteStepsRoute';
}

class AdminDeepRoute extends _i1.PageRouteInfo {
  const AdminDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'admin', initialChildren: children);

  AdminDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AdminDeepRoute';
}

class DraftsRoute extends _i1.PageRouteInfo {
  const DraftsRoute() : super(name, path: 'drafts');

  DraftsRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'DraftsRoute';
}

class FavouritesRoute extends _i1.PageRouteInfo {
  const FavouritesRoute() : super(name, path: 'fav');

  FavouritesRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'FavouritesRoute';
}

class QuotesListsDeepRoute extends _i1.PageRouteInfo {
  const QuotesListsDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'lists', initialChildren: children);

  QuotesListsDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'QuotesListsDeepRoute';
}

class MyPublishedQuotesRoute extends _i1.PageRouteInfo {
  const MyPublishedQuotesRoute() : super(name, path: 'published');

  MyPublishedQuotesRoute.fromMatch(_i1.RouteMatch match)
      : super.fromMatch(match);

  static const String name = 'MyPublishedQuotesRoute';
}

class MyTempQuotesRoute extends _i1.PageRouteInfo {
  const MyTempQuotesRoute() : super(name, path: 'temp');

  MyTempQuotesRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'MyTempQuotesRoute';
}

class DashboardSettingsDeepRoute extends _i1.PageRouteInfo {
  const DashboardSettingsDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'settings', initialChildren: children);

  DashboardSettingsDeepRoute.fromMatch(_i1.RouteMatch match)
      : super.fromMatch(match);

  static const String name = 'DashboardSettingsDeepRoute';
}

class QuotidiansRoute extends _i1.PageRouteInfo {
  const QuotidiansRoute() : super(name, path: 'quotidians');

  QuotidiansRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'QuotidiansRoute';
}

class AdminTempDeepRoute extends _i1.PageRouteInfo {
  const AdminTempDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'temp', initialChildren: children);

  AdminTempDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AdminTempDeepRoute';
}

class AdminTempQuotesRoute extends _i1.PageRouteInfo {
  const AdminTempQuotesRoute() : super(name, path: 'quotes');

  AdminTempQuotesRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AdminTempQuotesRoute';
}

class QuotesListsRoute extends _i1.PageRouteInfo {
  const QuotesListsRoute() : super(name, path: '');

  QuotesListsRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'QuotesListsRoute';
}

class QuotesListRoute extends _i1.PageRouteInfo {
  QuotesListRoute({this.listId, this.onResult})
      : super(name, path: ':listId', params: {'listId': listId});

  QuotesListRoute.fromMatch(_i1.RouteMatch match)
      : listId = match.pathParams.getString('listId'),
        onResult = null,
        super.fromMatch(match);

  final String listId;

  final void Function(bool) onResult;

  static const String name = 'QuotesListRoute';
}

class DashboardSettingsRoute extends _i1.PageRouteInfo {
  DashboardSettingsRoute({this.key, this.showAppBar = true})
      : super(name, path: '');

  DashboardSettingsRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        showAppBar = match.pathParams.getBool('showAppBar'),
        super.fromMatch(match);

  final _i40.Key key;

  final bool showAppBar;

  static const String name = 'DashboardSettingsRoute';
}

class DeleteAccountRoute extends _i1.PageRouteInfo {
  const DeleteAccountRoute() : super(name, path: 'delete/account');

  DeleteAccountRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'DeleteAccountRoute';
}

class AccountUpdateDeepRoute extends _i1.PageRouteInfo {
  const AccountUpdateDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'update', initialChildren: children);

  AccountUpdateDeepRoute.fromMatch(_i1.RouteMatch match)
      : super.fromMatch(match);

  static const String name = 'AccountUpdateDeepRoute';
}

class UpdateEmailRoute extends _i1.PageRouteInfo {
  const UpdateEmailRoute() : super(name, path: 'email');

  UpdateEmailRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'UpdateEmailRoute';
}

class UpdatePasswordRoute extends _i1.PageRouteInfo {
  const UpdatePasswordRoute() : super(name, path: 'password');

  UpdatePasswordRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'UpdatePasswordRoute';
}

class UpdateUsernameRoute extends _i1.PageRouteInfo {
  const UpdateUsernameRoute() : super(name, path: 'username');

  UpdateUsernameRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'UpdateUsernameRoute';
}

class TopicPageRoute extends _i1.PageRouteInfo {
  TopicPageRoute({this.topicName = '', this.decimal})
      : super(name, path: ':topicName', params: {'topicName': topicName});

  TopicPageRoute.fromMatch(_i1.RouteMatch match)
      : topicName = match.pathParams.getString('topicName', ''),
        decimal = null,
        super.fromMatch(match);

  final String topicName;

  final int decimal;

  static const String name = 'TopicPageRoute';
}

class ReferencesRoute extends _i1.PageRouteInfo {
  const ReferencesRoute() : super(name, path: '');

  ReferencesRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ReferencesRoute';
}

class ReferencePageRoute extends _i1.PageRouteInfo {
  ReferencePageRoute(
      {this.referenceId, this.referenceName, this.referenceImageUrl})
      : super(name, path: ':referenceId', params: {'referenceId': referenceId});

  ReferencePageRoute.fromMatch(_i1.RouteMatch match)
      : referenceId = match.pathParams.getString('referenceId'),
        referenceName = null,
        referenceImageUrl = null,
        super.fromMatch(match);

  final String referenceId;

  final String referenceName;

  final String referenceImageUrl;

  static const String name = 'ReferencePageRoute';
}

class GitHubRoute extends _i1.PageRouteInfo {
  const GitHubRoute() : super(name, path: 'github');

  GitHubRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'GitHubRoute';
}

class AndroidAppRoute extends _i1.PageRouteInfo {
  const AndroidAppRoute() : super(name, path: 'android');

  AndroidAppRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AndroidAppRoute';
}

class IosAppRoute extends _i1.PageRouteInfo {
  const IosAppRoute() : super(name, path: 'ios');

  IosAppRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'IosAppRoute';
}
