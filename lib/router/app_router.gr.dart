// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import '../screens/home/home.dart' as _i2;
import '../screens/about.dart' as _i3;
import '../screens/contact.dart' as _i4;
import '../screens/dashboard_page.dart' as _i5;
import '../screens/forgot_password.dart' as _i6;
import '../screens/settings.dart' as _i7;
import '../screens/search.dart' as _i8;
import '../screens/signin.dart' as _i9;
import '../screens/signup.dart' as _i10;
import '../screens/tos.dart' as _i11;
import '../screens/authors.dart' as _i12;
import '../screens/author_page.dart' as _i13;
import '../screens/add_quote/steps.dart' as _i14;
import '../screens/drafts.dart' as _i15;
import '../screens/favourites.dart' as _i16;
import '../screens/my_published_quotes.dart' as _i17;
import '../screens/my_temp_quotes.dart' as _i18;
import '../screens/quotes_lists.dart' as _i19;
import '../screens/quotes_list.dart' as _i20;
import '../screens/topic_page.dart' as _i21;
import '../screens/references.dart' as _i22;
import '../screens/reference_page.dart' as _i23;
import 'package:flutter/foundation.dart' as _i24;

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
    AboutRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i3.About());
    },
    AuthorsDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    ContactRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i4.Contact());
    },
    DashboardPageRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i5.DashboardPage());
    },
    TopicsDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    ForgotPasswordRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i6.ForgotPassword());
    },
    ReferencesDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    SettingsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i7.Settings());
    },
    SearchRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i8.Search());
    },
    SigninRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i9.Signin());
    },
    SignupRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i10.Signup());
    },
    TosRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i11.Tos());
    },
    AuthorsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i12.Authors());
    },
    AuthorPageRoute.name: (entry) {
      var route = entry.routeData.as<AuthorPageRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i13.AuthorPage(
              authorId: route.authorId,
              authorImageUrl: route.authorImageUrl ?? '',
              authorName: route.authorName ?? ''));
    },
    AddQuoteStepsRoute.name: (entry) {
      var route = entry.routeData.as<AddQuoteStepsRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i14.AddQuoteSteps(key: route.key, step: route.step ?? 0));
    },
    DraftsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i15.Drafts());
    },
    FavouritesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i16.Favourites());
    },
    QuotesListsDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    MyPublishedQuotesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i17.MyPublishedQuotes());
    },
    MyTempQuotesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i18.MyTempQuotes());
    },
    QuotesListsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i19.QuotesLists());
    },
    QuotesListRoute.name: (entry) {
      var route = entry.routeData.as<QuotesListRoute>();
      return _i1.MaterialPageX(
          entry: entry, child: _i20.QuotesList(listId: route.listId));
    },
    TopicPageRoute.name: (entry) {
      var route = entry.routeData.as<TopicPageRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i21.TopicPage(
              topicName: route.topicName ?? '', decimal: route.decimal));
    },
    ReferencesRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i22.References());
    },
    ReferencePageRoute.name: (entry) {
      var route = entry.routeData.as<ReferencePageRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i23.ReferencePage(
              referenceId: route.referenceId,
              referenceName: route.referenceName,
              referenceImageUrl: route.referenceImageUrl));
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
        _i1.RouteConfig<ContactRoute>(ContactRoute.name,
            path: '/contact',
            routeBuilder: (match) => ContactRoute.fromMatch(match)),
        _i1.RouteConfig<DashboardPageRoute>(DashboardPageRoute.name,
            path: '/dashboard',
            routeBuilder: (match) => DashboardPageRoute.fromMatch(match),
            children: [
              _i1.RouteConfig('#redirect',
                  path: '', redirectTo: 'fav', fullMatch: true),
              _i1.RouteConfig<AddQuoteStepsRoute>(AddQuoteStepsRoute.name,
                  path: 'addquote',
                  routeBuilder: (match) => AddQuoteStepsRoute.fromMatch(match)),
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
                  routeBuilder: (match) => MyTempQuotesRoute.fromMatch(match))
            ]),
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
            routeBuilder: (match) => SigninRoute.fromMatch(match)),
        _i1.RouteConfig<SignupRoute>(SignupRoute.name,
            path: '/signup',
            routeBuilder: (match) => SignupRoute.fromMatch(match)),
        _i1.RouteConfig<TosRoute>(TosRoute.name,
            path: '/tos', routeBuilder: (match) => TosRoute.fromMatch(match))
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

class ContactRoute extends _i1.PageRouteInfo {
  const ContactRoute() : super(name, path: '/contact');

  ContactRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ContactRoute';
}

class DashboardPageRoute extends _i1.PageRouteInfo {
  const DashboardPageRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/dashboard', initialChildren: children);

  DashboardPageRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'DashboardPageRoute';
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
  const SettingsRoute() : super(name, path: '/settings');

  SettingsRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'SettingsRoute';
}

class SearchRoute extends _i1.PageRouteInfo {
  const SearchRoute() : super(name, path: '/search');

  SearchRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'SearchRoute';
}

class SigninRoute extends _i1.PageRouteInfo {
  const SigninRoute() : super(name, path: '/signin');

  SigninRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'SigninRoute';
}

class SignupRoute extends _i1.PageRouteInfo {
  const SignupRoute() : super(name, path: '/signup');

  SignupRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'SignupRoute';
}

class TosRoute extends _i1.PageRouteInfo {
  const TosRoute() : super(name, path: '/tos');

  TosRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'TosRoute';
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

class AddQuoteStepsRoute extends _i1.PageRouteInfo {
  AddQuoteStepsRoute({this.key, this.step = 0})
      : super(name, path: 'addquote', queryParams: {'step': step});

  AddQuoteStepsRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        step = match.queryParams.getInt('step', 0),
        super.fromMatch(match);

  final _i24.Key key;

  final int step;

  static const String name = 'AddQuoteStepsRoute';
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

class QuotesListsRoute extends _i1.PageRouteInfo {
  const QuotesListsRoute() : super(name, path: '');

  QuotesListsRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'QuotesListsRoute';
}

class QuotesListRoute extends _i1.PageRouteInfo {
  QuotesListRoute({this.listId})
      : super(name, path: ':listId', params: {'listId': listId});

  QuotesListRoute.fromMatch(_i1.RouteMatch match)
      : listId = match.pathParams.getString('listId'),
        super.fromMatch(match);

  final String listId;

  static const String name = 'QuotesListRoute';
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
