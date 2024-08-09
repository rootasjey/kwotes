import "dart:async";

import "package:adaptive_theme/adaptive_theme.dart";
import "package:easy_localization/easy_localization.dart";
import "package:firebase_vertexai/firebase_vertexai.dart";
import "package:flutter/material.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:kwotes/components/empty_view.dart";
import "package:kwotes/components/loading_view.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/router/navigation_state_helper.dart";
import "package:kwotes/types/enums/enum_page_state.dart";
import "package:kwotes/types/quote.dart";
import "package:loggy/loggy.dart";

class ExplainQuoteSheet extends StatefulWidget {
  const ExplainQuoteSheet({
    super.key,
    required this.quote,
    this.scrollController,
  });

  /// Quote to explain.
  final Quote quote;

  /// Parent scroll controller (from bottom sheet).
  final ScrollController? scrollController;

  @override
  State<ExplainQuoteSheet> createState() => _ExplainQuoteSheetState();
}

class _ExplainQuoteSheetState extends State<ExplainQuoteSheet> with UiLoggy {
  /// Page's state (e.g. loading, idle, ...).
  EnumPageState _pageState = EnumPageState.idle;

  /// Prompt text result.
  String _textResult = "";

  /// Timer to vibrate when quote is displayed.
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    _vibrationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness? currentBrightness = AdaptiveTheme.of(context).brightness;
    final Color backgroundColor =
        currentBrightness == Brightness.dark ? Colors.black87 : Colors.white;

    if (_pageState == EnumPageState.loading) {
      return LoadingView.scaffold(
        message: "Carrot is thinking...",
        backgroundColor: backgroundColor,
      );
    }

    if (_pageState == EnumPageState.error) {
      return EmptyView.scaffold(
        context,
        backgroundColor: backgroundColor,
        title: "carrot.error.title".tr(),
        description: "carrot.error.overthought".tr(),
      );
    }

    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    // return SafeArea(
    //   child: Scaffold(
    //     backgroundColor: backgroundColor,
    //     body: CustomScrollView(
    //       controller: widget.scrollController,
    //       slivers: [
    //         SliverAppBar(
    //           pinned: true,
    //           expandedHeight: 78.0,
    //           automaticallyImplyLeading: false,
    //           backgroundColor: backgroundColor,
    //           foregroundColor: foregroundColor,
    //           flexibleSpace: FlexibleSpaceBar(
    //             title: Stack(
    //               children: [
    //                 Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         AppIcon(
    //                           size: 16.0,
    //                           onTap: () {},
    //                           margin: const EdgeInsets.only(
    //                             right: 8.0,
    //                           ),
    //                         ),
    //                         Text(
    //                           "Ask Carrot",
    //                           style: Utils.calligraphy.body(
    //                             textStyle: const TextStyle(
    //                               fontSize: 12.0,
    //                               fontWeight: FontWeight.w500,
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     Text(
    //                       "To know more about this quote",
    //                       style: Utils.calligraphy.body(
    //                         textStyle: TextStyle(
    //                           fontSize: 11.0,
    //                           fontWeight: FontWeight.w300,
    //                           color: foregroundColor?.withOpacity(0.6),
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 Positioned(
    //                   top: 0.0,
    //                   right: 0.0,
    //                   // alignment: Alignment.topRight,
    //                   child: Padding(
    //                     padding: const EdgeInsets.only(right: 8.0),
    //                     child: IconButton(
    //                       iconSize: 14.0,
    //                       onPressed: () => Navigator.of(context).pop(),
    //                       icon: const Icon(TablerIcons.x),
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         // Positioned(
    //         //   top: 6.0,
    //         //   right: 0.0,
    //         //   child: Padding(
    //         //     padding: const EdgeInsets.only(right: 8.0),
    //         //     child: IconButton(
    //         //       color: foregroundColor?.withOpacity(0.6),
    //         //       onPressed: () => Navigator.of(context).pop(),
    //         //       icon: const Icon(TablerIcons.x),
    //         //     ),
    //         //   ),
    //         // ),
    //         SliverToBoxAdapter(
    //           child: Container(
    //             height: MediaQuery.of(context).size.height - 160.0,
    //             padding: const EdgeInsets.all(8.0),
    //             child: Markdown(
    //               // shrinkWrap: true,
    //               // controller: widget.scrollController,
    //               selectable: true,
    //               data: _textResult,
    //               padding: const EdgeInsets.all(36.0),
    //               styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
    //               styleSheet: MarkdownStyleSheet(
    //                 h1: Utils.calligraphy.body(
    //                   textStyle: TextStyle(
    //                     fontSize: 32.0,
    //                     fontWeight: FontWeight.w500,
    //                     color: foregroundColor,
    //                   ),
    //                 ),
    //                 p: Utils.calligraphy.body(
    //                   textStyle: TextStyle(
    //                     fontSize: 16.0,
    //                     fontWeight: FontWeight.w400,
    //                     color: foregroundColor?.withOpacity(0.6),
    //                     letterSpacing: 0.5,
    //                   ),
    //                 ),
    //                 strong: Utils.calligraphy.body(
    //                   textStyle: TextStyle(
    //                     fontSize: 16.0,
    //                     fontWeight: FontWeight.w500,
    //                     color: foregroundColor,
    //                     letterSpacing: 0.5,
    //                   ),
    //                 ),
    //                 blockSpacing: 16.0,
    //                 listBullet: Utils.calligraphy.body(
    //                   textStyle: TextStyle(
    //                     fontSize: 16.0,
    //                     fontWeight: FontWeight.w500,
    //                     color: foregroundColor,
    //                     letterSpacing: 0.0,
    //                   ),
    //                 ),
    //                 horizontalRuleDecoration: BoxDecoration(
    //                   border: Border(
    //                     bottom: BorderSide(
    //                       color: Colors.grey.shade300,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Markdown(
                controller: widget.scrollController,
                selectable: true,
                data: _textResult,
                padding: const EdgeInsets.all(36.0),
                styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                styleSheet: MarkdownStyleSheet(
                  h1: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 52.0,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor,
                    ),
                  ),
                  h2: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 42.0,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor,
                    ),
                  ),
                  h3: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor,
                    ),
                  ),
                  h4: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor,
                    ),
                  ),
                  p: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: foregroundColor?.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  strong: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  blockSpacing: 16.0,
                  listBullet: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor,
                      letterSpacing: 0.0,
                    ),
                  ),
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: foregroundColor?.withOpacity(0.3) ??
                            Colors.grey.shade300,
                        // color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6.0,
              right: 0.0,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  color: foregroundColor?.withOpacity(0.6),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(TablerIcons.x),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetch() async {
    setState(() => _pageState = EnumPageState.loading);
    final Quote quote = widget.quote;

    // Provide a prompt that contains text
    String promptText = "Explain the following quote: \"${quote.name}\"";

    if (quote.author.id.isNotEmpty &&
        quote.author.id != "TySUhQPqndIkiVHWVYq1") {
      promptText += " by \"${quote.author.name}\"";
    }

    if (quote.reference.id.isNotEmpty) {
      promptText += " in \"${quote.reference.name}\"";
    }

    final List<Content> prompt = [Content.text(promptText)];

    final GenerativeModel? model = NavigationStateHelper.generativeModel;
    if (model == null) {
      if (!mounted) return;
      setState(() => _pageState = EnumPageState.error);
      return;
    }

    try {
      final GenerateContentResponse response =
          await model.generateContent(prompt);

      setState(() => _pageState = EnumPageState.idle);
      _textResult = "### 🥕 Ask Carrot \n\n --- \n\n";

      int count = 0;
      response.text?.characters.forEach((final String char) {
        count++;
        Future.delayed(Duration(milliseconds: 5 * count), () {
          if (!mounted) return;
          setState(() => _textResult += char);
        });
      });
    } catch (error) {
      loggy.error(error);
      if (!mounted) return;
      setState(() => _pageState = EnumPageState.error);
    }
  }
}
