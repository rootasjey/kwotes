import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/router/app_router.gr.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/brightness.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:figstyle/utils/push_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:figstyle/components/fade_in_x.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/language.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class Settings extends StatefulWidget {
  final bool showAppBar;

  const Settings({
    Key key,
    @PathParam('showAppBar') this.showAppBar = true,
  }) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isLoadingLang = false;
  bool isLoadingAvatarUrl = false;
  bool isNameAvailable = false;
  bool isThemeAuto = true;
  bool notificationsON = false;

  Brightness brightness;
  Brightness currentBrightness;

  double beginY = 20.0;

  String avatarUrl = '';
  String currentUserName = '';
  String email = '';
  String imageUrl = '';
  String notifLang = 'en';
  String selectedLang = 'English';

  Timer nameTimer;
  Timer timer;

  ScrollController _pageScrollController = ScrollController();

  @override
  initState() {
    super.initState();
    initNotifState();
    initBrightness();

    setState(() {
      selectedLang = Language.frontend(stateUser.lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        child: CustomScrollView(
          controller: _pageScrollController,
          slivers: <Widget>[
            if (widget.showAppBar) appBar(),
            body(),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;

    if (width < Constants.maxMobileWidth) {
      return PageAppBar(
        textTitle: "Settings",
        textSubTitle: "You can change your preferences here",
        titlePadding: const EdgeInsets.only(top: 8.0),
      );
    }

    return DesktopAppBar(
      title: "Settings",
      automaticallyImplyLeading: true,
    );
  }

  Widget accountSettings() {
    return Observer(
      builder: (_) {
        final isUserConnected = stateUser.isUserConnected;

        if (isUserConnected) {
          return Column(
            children: [
              FadeInY(
                delay: 0.milliseconds,
                beginY: 50.0,
                child: avatar(isUserConnected),
              ),
              accountActions(isUserConnected),
              FadeInY(
                delay: 100.milliseconds,
                beginY: 50.0,
                child: updateUsernameButton(isUserConnected),
              ),
              Padding(padding: const EdgeInsets.only(top: 20.0)),
              FadeInY(
                delay: 200.milliseconds,
                beginY: 50.0,
                child: emailButton(),
              ),
              Divider(
                thickness: 1.0,
                height: 50.0,
              ),
            ],
          );
        }

        return Column(
          children: [
            // SizedBox(
            //   width: 450.0,
            //   child: FadeInY(
            //     delay: 1.0,
            //     beginY: beginY,
            //     child: langSelect(),
            //   ),
            // ),
          ],
        );
      },
    );
  }

  Widget accountActions(bool isUserConnected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Wrap(
        spacing: 15.0,
        children: <Widget>[
          FadeInX(
            delay: 0.milliseconds,
            beginX: 50.0,
            child: updatePasswordButton(),
          ),
          FadeInX(
            delay: 100.milliseconds,
            beginX: 50.0,
            child: deleteAccountButton(),
          )
        ],
      ),
    );
  }

  Widget appSettings() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          themeSwitcher(),
          notificationSection(),
          Padding(
              padding: const EdgeInsets.only(
            bottom: 100.0,
          )),
        ],
      ),
    );
  }

  Widget avatar(bool isUserConnected) {
    // if (isLoadingImageURL) {
    //   return Padding(
    //     padding: const EdgeInsets.only(
    //       bottom: 30.0,
    //     ),
    //     child: Material(
    //       elevation: 4.0,
    //       shape: CircleBorder(),
    //       clipBehavior: Clip.hardEdge,
    //       child: InkWell(
    //         child: Padding(
    //           padding: const EdgeInsets.all(40.0),
    //           child: CircularProgressIndicator(),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 30.0,
      ),
      child: Material(
        elevation: 4.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Icon(
              UniconsLine.user_circle,
              color: stateColors.primary,
              size: 64.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget notificationSection() {
    if (kIsWeb) {
      return Container();
    }

    return SizedBox(
      width: 400.0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FadeInY(
                delay: 100.milliseconds,
                beginY: 10.0,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.0, left: 20.0),
                  child: Text(
                    'Notifications',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: stateColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              FadeInY(
                delay: 200.milliseconds,
                beginY: 10.0,
                child: SwitchListTile(
                  onChanged: (bool value) {
                    notificationsON = value;

                    timer?.cancel();
                    timer = Timer(Duration(seconds: 1),
                        () => toggleQuotidianNotifications());
                  },
                  value: notificationsON,
                  title: Text('Daily quote'),
                  subtitle: Text(
                      "If this is active, you will receive a quote at 8:00am everyday"),
                  secondary: notificationsON
                      ? Icon(Icons.notifications_active)
                      : Icon(Icons.notifications_off),
                ),
              ),
              if (notificationsON)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ListTile(
                    leading: Icon(Icons.language),
                    title: DropdownButton<String>(
                      elevation: 2,
                      isDense: true,
                      value: notifLang,
                      underline: Container(),
                      icon: Container(),
                      items: Language.available().map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            Language.frontend(value),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          notifLang = newValue;
                        });

                        PushNotifications.updateLangNotification(newValue);
                      },
                    ),
                    subtitle: Text(
                        "Your daily quote will be in the selected language"),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget body() {
    double paddingTop = 0.0;
    bool showBigTitle = false;

    if (MediaQuery.of(context).size.width > 700.0) {
      paddingTop = widget.showAppBar ? 100.0 : 20.0;
      showBigTitle = true;
    }

    return SliverPadding(
      padding: EdgeInsets.only(top: paddingTop),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (showBigTitle)
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (context.router.root.stack.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        onPressed: context.router.pop,
                        icon: Icon(Icons.arrow_back),
                      ),
                    ),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 80.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          accountSettings(),
          appSettings(),
        ]),
      ),
    );
  }

  Widget deleteAccountButton() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10.0),
          width: 90.0,
          height: 90.0,
          child: Card(
            elevation: 4.0,
            child: InkWell(
              onTap: () => context.router.push(
                DeleteAccountRoute(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(Icons.delete_outline),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: .8,
          child: Text(
            'Delete account',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        )
      ],
    );
  }

  Widget emailButton() {
    return FlatButton(
      onPressed: () async {
        context.router.push(
          AccountUpdateDeepRoute(
            children: [UpdateEmailRoute()],
          ),
        );
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 25.0,
                      right: 25.0,
                    ),
                    child: Text(
                      email,
                      style: TextStyle(
                        color: stateColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            });
      },
      child: Container(
        width: 250.0,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.alternate_email),
                ),
                Opacity(
                  opacity: .7,
                  child: Text(
                    'Email',
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 35.0),
                  child: Text(
                    email,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget ppCard({String imageName}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 90.0,
      child: Material(
        elevation: 3.0,
        color: stateColors.softBackground,
        shape: avatarUrl.replaceFirst('local:', '') == imageName
            ? CircleBorder(
                side: BorderSide(
                width: 2.0,
                color: stateColors.primary,
              ))
            : CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            updateImageUrl(imageName: imageName);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                'assets/images/$imageName-${stateColors.iconExt}.png'),
          ),
        ),
      ),
    );
  }

  Widget updateUsernameButton(bool isUserConnected) {
    return FlatButton(
      onPressed: () {
        context.router.push(
          AccountUpdateDeepRoute(
            children: [UpdateUsernameRoute()],
          ),
        );
      },
      child: Container(
        width: 250.0,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.person_outline),
                ),
                Opacity(
                  opacity: .7,
                  child: Text(
                    'Username',
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 35.0),
                  child: Text(
                    currentUserName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget langSelect() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: ListTile(
        leading: Icon(Icons.language),
        subtitle: Text("This will select the app's language"),
        title: DropdownButton<String>(
          elevation: 3,
          value: selectedLang,
          isDense: true,
          icon: Container(),
          underline: Container(),
          style: TextStyle(
            color: stateColors.foreground,
            fontFamily: GoogleFonts.raleway().fontFamily,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (String newValue) {
            setState(() {
              selectedLang = newValue;
            });

            updateLang();
          },
          items: ['English', 'Français'].map((String value) {
            return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                ));
          }).toList(),
        ),
      ),
    );
  }

  Widget themeSwitcher() {
    return Container(
      width: 400.0,
      padding: EdgeInsets.only(
        bottom: 60.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FadeInY(
            delay: 0.milliseconds,
            beginY: 10.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: stateColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FadeInY(
            delay: 100.milliseconds,
            beginY: 10.0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  themeDescription(),
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ),
          FadeInY(
            delay: 200.milliseconds,
            beginY: 10.0,
            child: SwitchListTile(
              title: Text('Automatic theme'),
              secondary: const Icon(Icons.autorenew),
              value: isThemeAuto,
              onChanged: (newValue) {
                setState(() => isThemeAuto = newValue);

                if (newValue) {
                  BrightnessUtils.setAutoBrightness(context);
                  return;
                }

                currentBrightness = appStorage.getBrightness();
                BrightnessUtils.setBrightness(context, currentBrightness);
              },
            ),
          ),
          if (!isThemeAuto)
            FadeInY(
              delay: 0.milliseconds,
              beginY: 10.0,
              child: SwitchListTile(
                title: Text('Lights'),
                secondary: const Icon(Icons.lightbulb_outline),
                value: currentBrightness == Brightness.light,
                onChanged: (newValue) {
                  currentBrightness =
                      newValue ? Brightness.light : Brightness.dark;

                  BrightnessUtils.setBrightness(context, currentBrightness);
                  setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget updatePasswordButton() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10.0),
          width: 90.0,
          height: 90.0,
          child: Card(
            elevation: 4.0,
            child: InkWell(
              onTap: () {
                context.router.push(
                  AccountUpdateDeepRoute(
                    children: [UpdatePasswordRoute()],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  Icons.lock,
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.8,
          child: Text(
            'Update password',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  AlertDialog showAvatarDialog() {
    final width = MediaQuery.of(context).size.width;

    return AlertDialog(
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
      title: Text(
        'Choose a profile picture',
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20.0,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Divider(
              thickness: 2.0,
            ),
            SizedBox(
              height: 150.0,
              width: width > 400.0 ? 400.0 : width,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: <Widget>[
                  FadeInX(
                    child: ppCard(
                      imageName: 'boy',
                    ),
                    delay: 100.milliseconds,
                    beginX: 50.0,
                  ),
                  FadeInX(
                    child: ppCard(imageName: 'employee'),
                    delay: 200.milliseconds,
                    beginX: 50.0,
                  ),
                  FadeInX(
                    child: ppCard(imageName: 'lady'),
                    delay: 300.milliseconds,
                    beginX: 50.0,
                  ),
                  FadeInX(
                    child: ppCard(
                      imageName: 'user',
                    ),
                    delay: 400.milliseconds,
                    beginX: 50.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initBrightness() {
    final autoBrightness = appStorage.getAutoBrightness();
    isThemeAuto = autoBrightness;

    if (!autoBrightness) {
      currentBrightness = appStorage.getBrightness();
    } else {
      Brightness brightness = Brightness.light;
      final now = DateTime.now();

      if (now.hour < 6 || now.hour > 17) {
        brightness = Brightness.dark;
      }

      currentBrightness = brightness;
    }
  }

  void initNotifState() async {
    if (kIsWeb) {
      return;
    }

    notificationsON = await PushNotifications.isActive();
    setState(() {});
  }

  void toggleQuotidianNotifications() async {
    if (notificationsON) {
      PushNotifications.activate();
      return;
    }

    PushNotifications.deactivate();
  }

  String themeDescription() {
    return isThemeAuto
        ? 'It will be chosen accordingly to the time of the day'
        : 'Choose your theme manually';
  }

  void updateImageUrl({String imageName}) async {
    setState(() => isLoadingAvatarUrl = true);

    try {
      final userAuth = stateUser.userAuth;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .update({
        'urls.image': 'local:$imageName',
      });

      setState(() {
        avatarUrl = 'local:$imageName';
        isLoadingAvatarUrl = false;
      });

      showSnack(
        context: context,
        message: 'Your image has been successfully updated.',
        type: SnackType.success,
      );
    } catch (error) {
      debugPrint(error.toString());

      setState(() => isLoadingAvatarUrl = false);

      showSnack(
        context: context,
        message: 'Oops, there was an error: ${error.toString()}',
        type: SnackType.error,
      );
    }
  }

  void updateLang() async {
    setState(() {
      isLoadingLang = true;
    });

    final lang = Language.backend(selectedLang);

    Language.setLang(lang);

    setState(() {
      isLoadingLang = false;
    });

    showSnack(
      context: context,
      message: 'Your language has been successfully updated.',
      type: SnackType.success,
    );
  }
}
