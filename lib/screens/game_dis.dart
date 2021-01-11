import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/components/empty_content.dart';
import 'package:figstyle/components/error_container.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/sliver_loading_view.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/types/quote.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

/// Game - Did I Say?
/// A simple game where the player guesses who is the quote's author
/// or in which reference the quote has been said.
class GameDIS extends StatefulWidget {
  @override
  _GameDISState createState() => _GameDISState();
}

class _GameDISState extends State<GameDIS> {
  bool isLoading = false;
  bool hasErrors = false;

  Quote quoteToGuess;

  GameState gameState = GameState.stopped;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DesktopAppBar(),
          pageTitle(),
          body(),
          SliverPadding(
            padding: const EdgeInsets.only(
              bottom: 300.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return SliverLoadingView();
    }

    if (!isLoading && hasErrors) {
      return errorView();
    }

    if (quoteToGuess == null) {
      return emptyView();
    }

    return gameScreen();
  }

  Widget emptyView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        FadeInY(
          delay: 200.milliseconds,
          beginY: 50.0,
          child: EmptyContent(
            icon: Opacity(
              opacity: .8,
              child: Icon(
                Icons.sentiment_neutral,
                size: 120.0,
                color: Color(0xFFFF005C),
              ),
            ),
            title:
                "Game's data couldn't be fetched. Please try reload the page or contact us.",
            subtitle: "We're sorry for the unconvenience.",
            onRefresh: () {},
          ),
        ),
      ]),
    );
  }

  Widget errorView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: ErrorContainer(
            onRefresh: () {},
          ),
        ),
      ]),
    );
  }

  Widget gameScreen() {
    switch (gameState) {
      case GameState.stopped:
        return startingScreen();
        break;
      case GameState.running:
        return runningScreen();
        break;
      case GameState.paused:
        return pausedScreen();
        break;
      case GameState.finished:
        return finishedScreen();
        break;
      default:
        return startingScreen();
    }
  }

  Widget pageTitle() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40.0, bottom: 20),
              child: Text(
                'Did I Say?',
                style: TextStyle(fontSize: 60.0),
              ),
            ),
            Text(
              "Can you correctly guess who said this quote? And in which reference?",
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ]),
    );
  }

  Widget startingScreen() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40.0, bottom: 20),
              child: Text(
                'Rules',
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            Text(
              "Can you correctly guess who said this quote? And in which reference?",
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ]),
    );
  }

  Widget runningScreen() {
    return Container();
  }

  Widget pausedScreen() {
    return Container();
  }

  Widget finishedScreen() {
    return Container();
  }
}
