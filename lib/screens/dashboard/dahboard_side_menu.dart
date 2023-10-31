import "package:adaptive_theme/adaptive_theme.dart";
import "package:beamer/beamer.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:just_the_tooltip/just_the_tooltip.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/screens/dashboard/side_menu_item.dart";
import "package:unicons/unicons.dart";

class DashboardSideMenu extends StatefulWidget {
  const DashboardSideMenu({
    super.key,
    required this.beamerKey,
  });

  final GlobalKey<BeamerState> beamerKey;

  @override
  State<DashboardSideMenu> createState() => _DashboardSideMenuState();
}

class _DashboardSideMenuState extends State<DashboardSideMenu> {
  late BeamerDelegate _beamerDelegate;

  @override
  void initState() {
    super.initState();
    // NOTE: Beamer state isn't ready on 1st frame
    // probably because [SidePanelMenu] appears before the Beamer widget.
    // So we use [addPostFrameCallback] to access the state in the next frame.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final BeamerState? currentState = widget.beamerKey.currentState;

      if (currentState != null) {
        _beamerDelegate = currentState.routerDelegate;
        _beamerDelegate.addListener(_setStateListener);
      }
    });
  }

  @override
  void dispose() {
    _beamerDelegate.removeListener(_setStateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Center(
        child: Material(
          elevation: isDark ? 8.0 : 0.0,
          color: isDark ? Colors.black45 : Colors.white38,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            width: 64.0,
            padding: const EdgeInsets.all(12.0),
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                getMenuItemList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getMenuItemList() {
    return SliverList.list(
      children: [
        SideMenuItem(
          iconData: TablerIcons.home,
          label: "home".tr(),
          hoverColor: Constants.colors.home,
          routePath: DashboardContentLocation.route,
        ),
        SideMenuItem(
          iconData: UniconsLine.heart,
          label: "favourites.name".tr(),
          hoverColor: Constants.colors.likes,
          routePath: DashboardContentLocation.favouritesRoute,
        ),
        SideMenuItem(
          iconData: UniconsLine.list_ul,
          label: "lists.name".tr(),
          hoverColor: Constants.colors.lists,
          routePath: DashboardContentLocation.listsRoute,
        ),
        SideMenuItem(
          iconData: UniconsLine.clock,
          label: "in_validation.name".tr(),
          hoverColor: Constants.colors.inValidation,
          routePath: DashboardContentLocation.inValidationRoute,
        ),
        SideMenuItem(
          iconData: TablerIcons.send,
          label: "published.name".tr(),
          hoverColor: Constants.colors.published,
          routePath: DashboardContentLocation.publishedRoute,
        ),
        SideMenuItem(
          iconData: TablerIcons.note,
          label: "drafts.name".tr(),
          hoverColor: Constants.colors.drafts,
          routePath: DashboardContentLocation.draftsRoute,
        ),
        SideMenuItem(
          iconData: UniconsLine.setting,
          label: "settings.name".tr(),
          hoverColor: Constants.colors.settings,
          routePath: DashboardContentLocation.settingsRoute,
        ),
      ].map(itemToWidget).toList(),
    );
  }

  Widget itemToWidget(SideMenuItem menuItem) {
    final Color foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    final bool pathMatch =
        context.currentBeamLocation.state.routeInformation.uri.toString() ==
            menuItem.routePath;

    final Color color =
        pathMatch ? menuItem.hoverColor : foregroundColor.withOpacity(0.6);

    return JustTheTooltip(
      preferredDirection: AxisDirection.left,
      backgroundColor: AdaptiveTheme.of(context).brightness == Brightness.dark
          ? Colors.black
          : null,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          menuItem.label,
          style: Utils.calligraphy.body(
            textStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: IconButton(
          onPressed: () {
            context.beamToNamed(menuItem.routePath);
            setState(() {});
          },
          color: color,
          icon: Icon(menuItem.iconData),
        ),
      ),
    );
  }

  void _setStateListener() => setState(() {});
}
