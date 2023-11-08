import "dart:async";
import "dart:ui";

import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/circle_button.dart";
import "package:kwotes/components/dot_indicator.dart";
import "package:kwotes/components/icons/app_icon.dart";
import "package:kwotes/components/letter_avatar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/locations/home_location.dart";
import "package:kwotes/router/locations/search_location.dart";
import "package:kwotes/router/locations/signin_location.dart";
import "package:kwotes/types/enums/enum_app_bar_mode.dart";
import "package:kwotes/types/enums/enum_search_category.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/user/user_auth.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:super_context_menu/super_context_menu.dart";
import "package:unicons/unicons.dart";

class ApplicationBar extends StatelessWidget {
  const ApplicationBar({
    Key? key,
    this.hideIcon = false,
    this.pinned = true,
    this.bottom,
    this.backgroundColor,
    this.toolbarHeight = 90.0,
    this.padding = const EdgeInsets.only(left: 24.0, top: 16.0, right: 24.0),
    this.isMobileSize = false,
    this.mode = EnumAppBarMode.home,
    this.onSelectSearchEntity,
    this.searchCategorySelected = EnumSearchCategory.quote,
    this.onTapIcon,
    this.onTapTitle,
    this.elevation,
    this.title,
    this.rightChildren = const [],
  }) : super(key: key);

  /// Hide the app bar icon if true.
  final bool hideIcon;

  /// Whether the app bar should remain visible at the start of the scroll view.
  final bool pinned;

  /// Adapt the user interface to small screens if true.
  final bool isMobileSize;

  /// The background color of the app bar.
  final Color? backgroundColor;

  /// The elevation of the app bar.
  final double? elevation;

  final double toolbarHeight;

  /// The padding of the app bar.
  final EdgeInsets padding;

  /// This widget appears across the bottom of the app bar.
  final PreferredSizeWidget? bottom;

  /// AppBar appareance according of the displayed page.
  final EnumAppBarMode mode;

  /// The selected search entity.
  /// Useful only on search page.
  final EnumSearchCategory searchCategorySelected;

  /// Callback fired when a different search entity is selected (e.g. author).
  final void Function(EnumSearchCategory searchEntity)? onSelectSearchEntity;

  /// Callback fired when app bar icon is tapped.
  final void Function()? onTapIcon;

  /// Callback fired when app bar title is tapped.
  final void Function()? onTapTitle;

  /// App bar title.
  final Widget? title;

  /// App bar right children.
  final List<Widget> rightChildren;

  @override
  Widget build(
    BuildContext context,
  ) {
    final Signal<UserAuth?> userAuthSignal =
        context.get<Signal<UserAuth?>>(EnumSignalId.userAuth);

    final Signal<UserFirestore> userFirestoreSignal =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);

    final String location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .uri
        .toString();

    final bool hasHistory = location != HomeLocation.route;
    final Color foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ??
            Colors.black;

    final EdgeInsets localPadding = padding.copyWith(
      left: isMobileSize ? 0.0 : padding.left,
    );

    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: pinned,
      elevation: elevation,
      toolbarHeight: toolbarHeight,
      backgroundColor: backgroundColor ??
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
      automaticallyImplyLeading: false,
      title: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: Padding(
          padding: localPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (hasHistory)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleButton.outlined(
                        borderColor: Colors.transparent,
                        onTap: () => Utils.passage.back(
                          context,
                          isMobile: isMobileSize,
                        ),
                        child: Icon(
                          UniconsLine.arrow_left,
                          color: foregroundColor,
                        ),
                      ),
                    ),
                  if (!hideIcon)
                    AppIcon(
                      size: 36.0,
                      onTap: onTapIcon,
                    ),
                  appBarTitle(context),
                ],
              ),
              Wrap(
                spacing: 12.0,
                children: [
                  ...rightChildren,
                  if (!isMobileSize) ...iconChildren(context),
                  if (!isMobileSize)
                    DualSignalBuilder(
                      firstSignal: userAuthSignal,
                      secondSignal: userFirestoreSignal,
                      builder: authButtonBuilder,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottom: bottom,
    );
  }

  List<Widget> iconChildren(BuildContext context) {
    final Color? defaultColor = Theme.of(context).textTheme.bodyMedium?.color;

    if (mode != EnumAppBarMode.search) {
      return [
        IconButton(
          onPressed: () {
            context.beamToNamed(SearchLocation.route);
          },
          tooltip: "search.name".tr(),
          color: defaultColor,
          icon: const Icon(UniconsLine.search),
        ),
      ];
    }

    final bool quoteSelected =
        searchCategorySelected == EnumSearchCategory.quote;
    final bool authorSelected =
        searchCategorySelected == EnumSearchCategory.author;
    final bool referenceSelected =
        searchCategorySelected == EnumSearchCategory.reference;

    return [
      Column(
        children: [
          IconButton(
            isSelected: quoteSelected,
            onPressed: () =>
                onSelectSearchEntity?.call(EnumSearchCategory.quote),
            tooltip: "search.quotes".tr(),
            color: quoteSelected ? Colors.pink : defaultColor,
            icon: const Icon(UniconsLine.chat),
          ),
          DotIndicator(
            color: quoteSelected ? Colors.pink : Colors.transparent,
          ),
        ],
      ),
      Column(
        children: [
          IconButton(
            isSelected: searchCategorySelected == EnumSearchCategory.author,
            onPressed: () =>
                onSelectSearchEntity?.call(EnumSearchCategory.author),
            tooltip: "search.authors".tr(),
            color: searchCategorySelected == EnumSearchCategory.author
                ? Colors.amber
                : defaultColor,
            icon: const Icon(TablerIcons.users),
          ),
          DotIndicator(
            color: authorSelected ? Colors.amber : Colors.transparent,
          ),
        ],
      ),
      Column(
        children: [
          IconButton(
            isSelected: searchCategorySelected == EnumSearchCategory.reference,
            onPressed: () =>
                onSelectSearchEntity?.call(EnumSearchCategory.reference),
            tooltip: "search.references".tr(),
            color: searchCategorySelected == EnumSearchCategory.reference
                ? Colors.blue
                : defaultColor,
            icon: const Icon(UniconsLine.book_alt),
          ),
          DotIndicator(
            color: referenceSelected ? Colors.blue : Colors.transparent,
          ),
        ],
      ),
    ];
  }

  Widget appBarTitle(BuildContext context) {
    if (title != null) {
      return title ?? Container();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: TextButton(
        onPressed: onTapTitle,
        child: Text(
          Constants.appName,
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget authButtonBuilder(
    BuildContext context,
    UserAuth? userAuth,
    UserFirestore userFirestore,
    Widget? child,
  ) {
    if (mode == EnumAppBarMode.signin) {
      return Container();
    }

    final Color foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8) ??
            Colors.black;

    if (userAuth != null && userAuth.uid.isNotEmpty) {
      return ContextMenuWidget(
        child: LetterAvatar(
          radius: 14.0,
          tooltip: "dashboard".tr(),
          margin: const EdgeInsets.only(top: 6.0),
          foregroundColor:
              Constants.colors.foregroundPalette.first.computeLuminance() > 0.4
                  ? Colors.black
                  : Colors.white,
          backgroundColor: Constants.colors.foregroundPalette.first,
          name: userAuth.displayName ?? "?",
          onTap: () => context.beamToNamed(DashboardLocation.route),
        ),
        menuProvider: (MenuRequest request) =>
            contextMenuProvider(request, context),
      );
    }

    return IconButton(
      onPressed: () => context.beamToNamed(SigninLocation.route),
      tooltip: "signin".tr(),
      color: foregroundColor,
      icon: const Icon(UniconsLine.user),
    );
  }

  FutureOr<Menu?> contextMenuProvider(
    MenuRequest request,
    BuildContext context,
  ) {
    return Menu(children: [
      MenuAction(
        title: "dashboard".tr(),
        callback: () => context.beamToNamed(DashboardLocation.route),
      ),
      MenuSeparator(),
      MenuAction(
        title: "favourites.name".tr(),
        image: MenuImage.icon(UniconsLine.heart),
        callback: () => context.beamToNamed(
          DashboardContentLocation.favouritesRoute,
        ),
      ),
      MenuAction(
        title: "lists.name".tr(),
        image: MenuImage.icon(UniconsLine.list_ul),
        callback: () => context.beamToNamed(
          DashboardContentLocation.listsRoute,
        ),
      ),
      MenuAction(
        title: "in_validation.name".tr(),
        image: MenuImage.icon(UniconsLine.clock),
        callback: () =>
            context.beamToNamed(DashboardContentLocation.inValidationRoute),
      ),
      MenuAction(
        title: "published.name".tr(),
        image: MenuImage.icon(UniconsLine.upload),
        callback: () =>
            context.beamToNamed(DashboardContentLocation.publishedRoute),
      ),
      MenuAction(
        title: "drafts.name".tr(),
        image: MenuImage.icon(UniconsLine.notes),
        callback: () =>
            context.beamToNamed(DashboardContentLocation.draftsRoute),
      ),
      MenuAction(
        title: "settings.name".tr(),
        image: MenuImage.icon(UniconsLine.setting),
        callback: () =>
            context.beamToNamed(DashboardContentLocation.settingsRoute),
      ),
      MenuSeparator(),
      MenuAction(
        title: "logout.name".tr(),
        image: MenuImage.icon(UniconsLine.signout),
        callback: () {
          Utils.state.logout();
          Beamer.of(context, root: true)
              .beamToReplacementNamed(HomeLocation.route);
        },
      ),
    ]);
  }
}
