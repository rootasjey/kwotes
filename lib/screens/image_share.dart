import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/topics_colors.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:figstyle/utils/animation.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

class ImageShare extends StatefulWidget {
  final ScrollController scrollController;
  final Quote quote;

  ImageShare({this.scrollController, this.quote});

  @override
  _ImageShareState createState() => _ImageShareState();
}

class _ImageShareState extends State<ImageShare> {
  ImageShareColor imageShareColor;
  Color accentColor = Colors.blue;
  GlobalKey previewContainer = new GlobalKey();

  @override
  void initState() {
    super.initState();

    initProps();

    setState(() {
      final topicColor = appTopicsColors.find(widget.quote.topics.first);
      accentColor =
          topicColor != null ? Color(topicColor.decimal) : accentColor;
    });
  }

  void initProps() {
    imageShareColor = appStorage.getImageShareColor();
  }

  @override
  Widget build(BuildContext context) {
    // print("getBackgroundColor: ${getBackgroundColor()}");
    // print("getForegroundColor: ${getForegroundColor()}");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final quote = widget.quote;

          ShareFilesAndScreenshotWidgets().shareScreenshot(
            previewContainer,
            1024,
            "fig.style - quote - ${quote.id}",
            "fig.style_quote_${quote.id}.png",
            "image/png",
            text: "fig.style - quote",
          );
        },
        child: Icon(
          Icons.ios_share,
          color: Colors.white,
        ),
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        controller: widget.scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            title: Text('Share image'),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close),
              ),
            ],
          ),
          imagePreview(),
          controls(),
        ],
      ),
    );
  }

  Widget imagePreview() {
    final size = 480.0;
    final quote = widget.quote;

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        RepaintBoundary(
          key: previewContainer,
          child: Center(
            child: Container(
              width: size,
              // height: size,
              child: Card(
                color: getBackgroundColor(),
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 30.0,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: AppIcon(
                          size: 40.0,
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            bottom: 20.0,
                          ),
                        ),
                      ),
                      createHeroQuoteAnimation(
                        quote: quote,
                        isMobile: true,
                        screenWidth: size - 20.0,
                        screenHeight: size - 20.0,
                        style: TextStyle(
                          color: getForegroundColor(),
                        ),
                      ),
                      SizedBox(
                        width: 60.0,
                        child: Divider(
                          thickness: 2.0,
                          height: 40.0,
                          color: getDividerColor(),
                        ),
                      ),
                      Opacity(
                        opacity: 0.6,
                        child: Text(
                          quote.author.name,
                          style: TextStyle(
                            color: getForegroundColor(),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (quote.mainReference != null &&
                          quote.mainReference.name.isNotEmpty)
                        Opacity(
                          opacity: 0.6,
                          child: Text(
                            quote.mainReference.name,
                            style: TextStyle(
                              color: getForegroundColor(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget controls() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Wrap(
            spacing: 20.0,
            alignment: WrapAlignment.center,
            children: [
              colorCard(
                onTap: () {
                  setState(() {
                    imageShareColor = ImageShareColor.light;
                  });
                },
                color: Color(0xffeeeeee),
                title: "Light",
              ),
              colorCard(
                onTap: () {
                  setState(() {
                    imageShareColor = ImageShareColor.dark;
                  });
                },
                color: Color(0xff101010),
                title: "Dark",
              ),
              colorCard(
                onTap: () {
                  setState(() {
                    imageShareColor = ImageShareColor.colored;
                  });
                },
                color: accentColor,
                title: "Colored",
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget colorCard({
    @required Color color,
    @required String title,
    @required VoidCallback onTap,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 80.0,
          height: 80.0,
          child: Card(
            color: color,
            elevation: 4.0,
            child: InkWell(
              onTap: () {
                onTap();
                appStorage.setImageShareColor(imageShareColor);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color getBackgroundColor() {
    if (imageShareColor == ImageShareColor.dark) {
      return stateColors.dark;
    }

    if (imageShareColor == ImageShareColor.light) {
      return stateColors.light;
    }

    if (imageShareColor == ImageShareColor.colored) {
      return accentColor;
    }

    return stateColors.dark;
  }

  Color getDividerColor() {
    if (imageShareColor == ImageShareColor.colored) {
      return Colors.white;
    }

    return accentColor;
  }

  Color getForegroundColor() {
    if (imageShareColor == ImageShareColor.dark) {
      return Colors.white;
    }

    if (imageShareColor == ImageShareColor.light) {
      return Colors.black;
    }

    if (imageShareColor == ImageShareColor.colored) {
      return Colors.white;
    }

    return Colors.white;
  }
}
