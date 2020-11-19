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
  Color accentColor = Colors.blue;

  final gradientColors = <Color>[];

  GlobalKey previewContainer = new GlobalKey();

  ImageShareColor imageShareColor;

  ImageShareTextColor imageShareTextColor;

  @override
  void initState() {
    super.initState();

    initProps();
    initColors();
  }

  void initColors() {
    widget.quote.topics.forEach((topic) {
      final topicColor = appTopicsColors.find(topic);
      gradientColors.add(Color(topicColor.decimal));
    });

    setState(() {
      accentColor = gradientColors.first;
    });
  }

  void initProps() {
    imageShareColor = appStorage.getImageShareColor();
    imageShareTextColor = appStorage.getImageShareTextColors();
  }

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: stateColors.background,
            automaticallyImplyLeading: false,
            title: Text(
              'Share image',
              style: TextStyle(
                color: stateColors.foreground,
              ),
            ),
            actions: [
              IconButton(
                color: stateColors.foreground,
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
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
              child: Card(
                color: getBackgroundColor(),
                elevation: 2.0,
                child: Container(
                  decoration: imageShareColor == ImageShareColor.gradient
                      ? BoxDecoration(gradient: getGradientColor())
                      : BoxDecoration(),
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
          backgroundControls(),
          textControls(),
        ]),
      ),
    );
  }

  Widget backgroundControls() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(Icons.image_outlined),
                ),
                Expanded(
                  child: Text(
                    "Background",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
              if (gradientColors.length > 1)
                colorCard(
                  onTap: () {
                    setState(() {
                      imageShareColor = ImageShareColor.gradient;
                    });
                  },
                  title: "Gradient",
                  color: Colors.transparent,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textControls() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        top: 60.0,
        bottom: 60.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(Icons.text_fields),
                ),
                Expanded(
                  child: Text(
                    "Text",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 20.0,
            alignment: WrapAlignment.center,
            children: [
              textColorCard(
                onTap: () {
                  setState(() {
                    imageShareTextColor = ImageShareTextColor.auto;
                  });
                },
                color: Colors.transparent,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.black],
                ),
                title: "Auto",
              ),
              textColorCard(
                onTap: () {
                  setState(() {
                    imageShareTextColor = ImageShareTextColor.light;
                  });
                },
                color: Color(0xffeeeeee),
                title: "Light",
              ),
              textColorCard(
                onTap: () {
                  setState(() {
                    imageShareTextColor = ImageShareTextColor.dark;
                  });
                },
                color: Color(0xff101010),
                title: "Dark",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget colorCard({
    @required Color color,
    Gradient gradient,
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
            clipBehavior: Clip.hardEdge,
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
              ),
              child: InkWell(
                onTap: () {
                  onTap();
                  appStorage.setImageShareColor(imageShareColor);
                },
              ),
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

  Widget textColorCard({
    @required Color color,
    Gradient gradient,
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
            clipBehavior: Clip.hardEdge,
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
              ),
              child: InkWell(
                onTap: () {
                  onTap();
                  appStorage.setImageShareTextColor(imageShareTextColor);
                },
              ),
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

    if (imageShareColor == ImageShareColor.gradient) {
      return Colors.transparent;
    }

    return stateColors.dark;
  }

  Gradient getGradientColor() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    );
  }

  Color getDividerColor() {
    if (imageShareColor == ImageShareColor.colored) {
      return Colors.white;
    }

    if (imageShareColor == ImageShareColor.gradient) {
      return Colors.white;
    }

    return accentColor;
  }

  Color getForegroundColor() {
    if (imageShareTextColor == ImageShareTextColor.dark) {
      return Colors.black;
    }

    if (imageShareTextColor == ImageShareTextColor.light) {
      return Colors.white;
    }

    return getAutoForegroundColor();
  }

  Color getAutoForegroundColor() {
    if (imageShareColor == ImageShareColor.dark) {
      return Colors.white;
    }

    if (imageShareColor == ImageShareColor.light) {
      return Colors.black;
    }

    if (imageShareColor == ImageShareColor.colored) {
      return Colors.white;
    }

    if (imageShareColor == ImageShareColor.gradient) {
      return Colors.white;
    }

    return Colors.white;
  }
}
