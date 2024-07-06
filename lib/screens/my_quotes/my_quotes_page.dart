import "package:beamer/beamer.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_improved_scrolling/flutter_improved_scrolling.dart";
import "package:flutter_solidart/flutter_solidart.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/buttons/new_quote_button.dart";
import "package:kwotes/components/custom_scroll_behaviour.dart";
import "package:kwotes/components/page_app_bar.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/locations/dashboard_location.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/screens/drafts/drafts_page.dart";
import "package:kwotes/screens/in_validation/in_validation_page.dart";
import "package:kwotes/screens/my_quotes/my_quotes_page_header.dart";
import "package:kwotes/screens/published/header_filter.dart";
import "package:kwotes/screens/published/published_page.dart";
import "package:kwotes/types/enums/enum_data_ownership.dart";
import "package:kwotes/types/enums/enum_language_selection.dart";
import "package:kwotes/types/enums/enum_my_quotes_tab.dart";
import "package:kwotes/types/enums/enum_signal_id.dart";
import "package:kwotes/types/quote.dart";
import "package:kwotes/types/user/user_firestore.dart";
import "package:vibration/vibration.dart";
import "package:wave_divider/wave_divider.dart";

class MyQuotesPage extends StatefulWidget {
  const MyQuotesPage({super.key});

  @override
  State<MyQuotesPage> createState() => _MyQuotesPageState();
}

class _MyQuotesPageState extends State<MyQuotesPage> {
  /// True if we already handled the quick action
  /// (e.g. pull/push to trigger).
  bool _handleQuickAction = false;

  /// Previous scroll position.
  /// Used to determine if the user is scrolling up or down.
  double _prevPixelsPosition = 0.0;

  /// Trigger offset for pull to action.
  final double _pullTriggerOffset = -100.0;

  /// Current selected tab.
  EnumMyQuotesTab _selectedTab = EnumMyQuotesTab.drafts;

  /// Current selected language to fetch quotes in validation.
  EnumLanguageSelection _selectedLanguage = EnumLanguageSelection.all;

  /// Selected tab index (owned | all).
  EnumDataOwnership _selectedOwnership = EnumDataOwnership.owned;

  /// Page's scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  @override
  initState() {
    super.initState();
    initProps();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobileSize = Utils.measurements.isMobileSize(context);
    final List<Widget> bodyChildren = [
      DraftsPage(
        isInTab: true,
        selectedLanguage: _selectedLanguage,
        pageScrollController: _pageScrollController,
      ),
      InValidationPage(
        isInTab: true,
        selectedLanguage: _selectedLanguage,
        selectedOwnership: _selectedOwnership,
        pageScrollController: _pageScrollController,
      ),
      PublishedPage(
        isInTab: true,
        selectedLanguage: _selectedLanguage,
        selectedOwnership: _selectedOwnership,
        pageScrollController: _pageScrollController,
      ),
    ];

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    return SafeArea(
      child: Scaffold(
        body: ImprovedScrolling(
          onScroll: onScroll,
          scrollController: _pageScrollController,
          child: ScrollConfiguration(
            behavior: const CustomScrollBehavior(),
            child: CustomScrollView(
              controller: _pageScrollController,
              slivers: [
                PageAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  isMobileSize: isMobileSize,
                  toolbarHeight: isMobileSize ? 194.0 : 282.0,
                  hideBackButton: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Beamer.of(context).beamBack(),
                          icon: const Icon(TablerIcons.arrow_left),
                        ),
                        NewQuoteButton(
                          isDark: isDark,
                          foregroundColor: foregroundColor,
                          verticalButtonPadding: isMobileSize ? 8.0 : 16.0,
                          // verticalButtonPadding: isMobileSize ? 16.0 : 16.0,
                          onTapNewQuoteButton: onGoToAddQuotePage,
                          margin: const EdgeInsets.only(right: 8.0),
                        ),
                      ],
                    ),
                    MyQuotesPageHeader(
                      onTapTitle: onTapTitle,
                      selectedTab: _selectedTab,
                      onSelectTab: onSelectTab,
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: const WaveDivider(
                    padding: EdgeInsets.symmetric(
                      vertical: 24.0,
                    ),
                  ).animate().fadeIn(
                        duration: const Duration(milliseconds: 1500),
                        begin: 0.0,
                      ),
                ),
                bodyChildren[getSelectedTabIndex(_selectedTab)],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Set the target variable to the new value.
  /// Then set the value back to its original value after 1 second.
  void boomerangQuickActionValue(bool newValue) {
    _handleQuickAction = newValue;
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _handleQuickAction = !newValue,
    );
  }

  int getSelectedTabIndex(EnumMyQuotesTab tab) {
    switch (tab) {
      case EnumMyQuotesTab.drafts:
        return 0;
      case EnumMyQuotesTab.inValidation:
        return 1;
      case EnumMyQuotesTab.published:
        return 2;
    }
  }

  /// Initialize properties.
  void initProps() async {
    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);
    final UserFirestore userFirestore = signalUserFirestore.value;

    final bool canManageQuotes = userFirestore.rights.canManageQuotes;
    _selectedOwnership = canManageQuotes
        ? await Utils.vault.getDataOwnership()
        : EnumDataOwnership.owned;

    _selectedLanguage = await Utils.vault.getPageLanguage();
    final int savedTabIndex = await Utils.vault.getMyQuotesPageTabIndex();

    setState(() {
      if (savedTabIndex != -1) {
        _selectedTab = EnumMyQuotesTab.values[savedTabIndex];
      }
    });
  }

  /// Navigate to the add/edit quote page.
  void onGoToAddQuotePage(BuildContext context) {
    if (!Utils.passage.canAddQuote(context)) return;
    NavigationStateHelper.quote = Quote.empty();
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }

  void onTapTitle() {
    _pageScrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  void onSelectTab(EnumMyQuotesTab newTab) {
    if (_selectedTab == newTab) {
      openFilterDialog(newTab);
      return;
    }

    Utils.vault.setMyQuotesPageTabIndex(getSelectedTabIndex(newTab));
    setState(() => _selectedTab = newTab);
  }

  void onPressedFab() {
    context.beamToNamed(DashboardContentLocation.addQuoteRoute);
  }

  /// Callback on scroll.
  void onScroll(double offset) {
    final double pixelsPosition = _pageScrollController.position.pixels;

    if (pixelsPosition < _pageScrollController.position.minScrollExtent) {
      if (_prevPixelsPosition <= pixelsPosition) {
        return;
      }

      _prevPixelsPosition = pixelsPosition;
      if (pixelsPosition < _pullTriggerOffset && !_handleQuickAction) {
        boomerangQuickActionValue(true);
        if (Utils.graphic.isMobile()) {
          Vibration.vibrate(amplitude: 20, duration: 25);
        }

        onGoToAddQuotePage(context);
      }
      return;
    }
  }

  /// Callback to select a language.
  void onSelectedLanguage(EnumLanguageSelection language) {
    if (_selectedLanguage == language) {
      return;
    }

    setState(() => _selectedLanguage = language);
    Utils.vault.setPageLanguage(language);
  }

  /// Callback to filter published quotes (owned | all).
  void onSelectedOnwership(EnumDataOwnership ownership) {
    if (_selectedOwnership == ownership) {
      return;
    }

    setState(() => _selectedOwnership = ownership);
    Utils.vault.setDataOwnership(ownership);
  }

  void openFilterDialog(EnumMyQuotesTab newTab) {
    final Signal<UserFirestore> signalUserFirestore =
        context.get<Signal<UserFirestore>>(EnumSignalId.userFirestore);
    final UserFirestore userFirestore = signalUserFirestore.value;
    final bool canManageQuotes = userFirestore.rights.canManageQuotes;

    void Function(EnumDataOwnership)? onSelectOwnership;

    if (newTab == EnumMyQuotesTab.inValidation && canManageQuotes) {
      onSelectOwnership = onSelectedOnwership;
    } else if (newTab == EnumMyQuotesTab.published && canManageQuotes) {
      onSelectOwnership = onSelectedOnwership;
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color chipBackgroundColor = getChipBackgroundColor(
      isDark: isDark,
      tab: newTab,
    );

    final bool showAllOwnership =
        newTab == EnumMyQuotesTab.published || canManageQuotes;

    final bool isIpad = NavigationStateHelper.isIpad;

    final bool isMobileSize =
        Utils.measurements.isMobileSize(context) || isIpad;

    Utils.graphic.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize || isIpad,
      builder: (BuildContext context) {
        return Align(
          heightFactor: 1.0,
          alignment: Alignment.bottomCenter,
          child: Material(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: isIpad ? 160.0 : 24.0,
                top: 12.0,
              ),
              child: HeaderFilter(
                direction: Axis.vertical,
                showAllOwnership: showAllOwnership,
                chipSelectedColor: getChipSelectedColor(newTab),
                chipBackgroundColor: chipBackgroundColor,
                selectedOwnership: _selectedOwnership,
                onSelectedOwnership: onSelectOwnership,
                selectedLanguage: _selectedLanguage,
                onSelectLanguage: (EnumLanguageSelection language) {
                  onSelectedLanguage(language);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Color getChipSelectedColor(EnumMyQuotesTab newTab) {
    switch (newTab) {
      case EnumMyQuotesTab.drafts:
        return Constants.colors.drafts;
      case EnumMyQuotesTab.inValidation:
        return Constants.colors.inValidation;
      case EnumMyQuotesTab.published:
        return Constants.colors.published;
    }
  }

  Color getChipBackgroundColor(
      {required bool isDark, required EnumMyQuotesTab tab}) {
    switch (tab) {
      case EnumMyQuotesTab.drafts:
        return isDark ? Colors.grey.shade800 : Colors.pink.shade50;
      case EnumMyQuotesTab.inValidation:
        return isDark ? Colors.grey.shade800 : Colors.blue.shade50;
      case EnumMyQuotesTab.published:
        return isDark ? Colors.grey.shade800 : Colors.green.shade50;
    }
  }
}
