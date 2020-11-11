import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/fade_in_x.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/components/desktop_app_bar.dart';
import 'package:figstyle/screens/delete_account.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/screens/update_email.dart';
import 'package:figstyle/screens/update_password.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user_state.dart';
import 'package:figstyle/utils/app_storage.dart';
import 'package:figstyle/utils/language.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isCheckingName = false;
  bool isLoadingLang = false;
  bool isLoadingName = false;
  bool isLoadingImageURL = false;
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
  String nameErrorMessage = '';
  String newUserName = '';
  String notifLang = 'en';
  String selectedLang = 'English';

  Timer nameTimer;
  Timer timer;

  ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    getLocalLang();
    checkAuth();
    initNotifState();

    isThemeAuto = appStorage.getAutoBrightness();
    currentBrightness = DynamicTheme.of(context).brightness;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: () async {
            await checkAuth();
            return null;
          },
          child: NotificationListener<ScrollNotification>(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                appBar(),
                body(),
              ],
            ),
          )),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;

    if (width < 700.0) {
      return PageAppBar(
        textTitle: "Settings",
        showNavBackIcon: true,
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
        final isUserConnected = userState.isUserConnected;

        if (isUserConnected) {
          return Wrap(
            alignment: WrapAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FadeInY(
                    delay: 0.0,
                    beginY: 50.0,
                    child: avatar(isUserConnected),
                  ),
                  accountActions(isUserConnected),
                ],
              ),
              Column(
                children: <Widget>[
                  FadeInY(
                    delay: 0.2,
                    beginY: 50.0,
                    child: updateNameButton(isUserConnected),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 20.0)),
                  FadeInY(
                    delay: 0.3,
                    beginY: 50.0,
                    child: emailButton(),
                  ),
                  // FadeInY(
                  //   delay: 0.4,
                  //   beginY: 50.0,
                  //   child: langSelect(),
                  // ),
                ],
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
            delay: 0.0,
            beginX: 50.0,
            child: updatePasswordButton(),
          ),
          FadeInX(
            delay: 0.2,
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
          Padding(
            padding: const EdgeInsets.only(
              bottom: 50.0,
            ),
            child: themeSwitcher(),
          ),
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
    if (isLoadingImageURL) {
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
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    String path = avatarUrl.replaceFirst('local:', '');
    path = 'assets/images/$path-${stateColors.iconExt}.png';

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
            child: avatarUrl.isEmpty
                ? Image.asset('assets/images/user-${stateColors.iconExt}.png',
                    width: 80.0)
                : Image.asset(path, width: 80.0),
          ),
          onTap: isUserConnected
              ? () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return showAvatarDialog();
                    },
                  );
                }
              : null,
        ),
      ),
    );
  }

  Widget notificationSection() {
    return SizedBox(
      width: 400.0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 40.0, bottom: 20.0, left: 20.0),
                child: Text(
                  'Notifications',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              SwitchListTile(
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
    return SliverPadding(
      padding: const EdgeInsets.only(top: 60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          accountSettings(),
          Divider(
            thickness: 1.0,
            height: 50.0,
          ),
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
              onTap: () async {
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => DeleteAccount()));

                if (!userState.isUserConnected) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => Signin()));
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(Icons.delete_forever),
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
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => UpdateEmail()));
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

  Widget updateNameButton(bool isUserConnected) {
    if (isLoadingName) {
      return SizedBox(
        height: 200.0,
        width: 300.0,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text('Updating your display name...'),
            )
          ],
        ),
      );
    }

    return FlatButton(
      onPressed: () {
        showUpdateNameDialog();
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

  Future showUpdateNameDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, childSetState) {
              return AlertDialog(
                title: Text(
                  'Update username',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                ),
                actionsPadding: const EdgeInsets.all(10.0),
                content: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Divider(
                        color: stateColors.secondary,
                        thickness: 1.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              autofocus: true,
                              decoration: InputDecoration(
                                icon: Icon(Icons.person_outline),
                                labelText: currentUserName.isEmpty
                                    ? 'Display name'
                                    : currentUserName,
                              ),
                              keyboardType: TextInputType.text,
                              onChanged: (value) async {
                                childSetState(() {
                                  newUserName = value;
                                  isCheckingName = true;
                                });

                                final isWellFormatted =
                                    checkUsernameFormat(newUserName);

                                if (!isWellFormatted) {
                                  childSetState(() {
                                    isCheckingName = false;
                                    nameErrorMessage = newUserName.length < 3
                                        ? 'Please use at least 3 characters'
                                        : 'Please use alpha-numerical (A-Z, 0-9) characters and underscore (_)';
                                  });

                                  return;
                                }

                                if (nameTimer != null) {
                                  nameTimer.cancel();
                                  nameTimer = null;
                                }

                                nameTimer = Timer(1.seconds, () async {
                                  isNameAvailable =
                                      await checkNameAvailability(newUserName);

                                  if (!isNameAvailable) {
                                    childSetState(() {
                                      isCheckingName = false;
                                      nameErrorMessage =
                                          'This name is not available';
                                    });

                                    return;
                                  }

                                  childSetState(() {
                                    isCheckingName = false;
                                    nameErrorMessage = '';
                                  });
                                });
                              },
                            ),
                            if (isCheckingName)
                              Container(
                                width: 230.0,
                                padding: const EdgeInsets.only(left: 40.0),
                                child: LinearProgressIndicator(),
                              ),
                            if (nameErrorMessage.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40.0, top: 5.0),
                                child: Text(
                                  nameErrorMessage,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      childSetState(() {
                        isCheckingName = false;
                        nameErrorMessage = '';
                      });

                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: stateColors.foreground.withOpacity(.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: isNameAvailable
                        ? () {
                            Navigator.of(context).pop();
                            updateUsername();
                          }
                        : null,
                    color: stateColors.primary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'UPDATE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        });
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
    return SizedBox(
      width: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FadeInY(
            delay: 2.0,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          FadeInY(
            delay: 3.0,
            beginY: 10.0,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                top: 15.0,
                bottom: 30.0,
              ),
              child: Opacity(
                opacity: .6,
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
            delay: 4.0,
            beginY: 10.0,
            child: SwitchListTile(
              title: Text('Automatic theme'),
              secondary: const Icon(Icons.autorenew),
              value: isThemeAuto,
              onChanged: (newValue) {
                if (!newValue) {
                  currentBrightness = appStorage.getBrightness();
                  DynamicTheme.of(context).setBrightness(currentBrightness);
                  stateColors.refreshTheme(currentBrightness);
                }

                appStorage.setAutoBrightness(newValue);

                if (newValue) {
                  setAutoBrightness();
                }

                setState(() {
                  isThemeAuto = newValue;
                });
              },
            ),
          ),
          if (!isThemeAuto)
            FadeInY(
              delay: 0,
              beginY: 10.0,
              child: SwitchListTile(
                title: Text('Lights'),
                secondary: const Icon(Icons.lightbulb_outline),
                value: currentBrightness == Brightness.light,
                onChanged: (newValue) {
                  currentBrightness =
                      newValue ? Brightness.light : Brightness.dark;

                  DynamicTheme.of(context).setBrightness(currentBrightness);
                  stateColors.refreshTheme(currentBrightness);

                  appStorage.setBrightness(currentBrightness);

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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => UpdatePassword()));
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
                    delay: 1,
                    beginX: 50.0,
                  ),
                  FadeInX(
                    child: ppCard(imageName: 'employee'),
                    delay: 1.2,
                    beginX: 50.0,
                  ),
                  FadeInX(
                    child: ppCard(imageName: 'lady'),
                    delay: 1.3,
                    beginX: 50.0,
                  ),
                  FadeInX(
                    child: ppCard(
                      imageName: 'user',
                    ),
                    delay: 1.4,
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

  void toggleQuotidianNotifications() async {
    if (notificationsON) {
      PushNotifications.activate();
      return;
    }

    PushNotifications.deactivate();
  }

  Future checkAuth() async {
    setState(() {
      isLoadingImageURL = true;
      isLoadingName = true;
      isLoadingLang = true;
    });

    try {
      final userAuth = await userState.userAuth;

      if (userAuth == null) {
        userState.setUserDisconnected();

        setState(() {
          isLoadingImageURL = false;
          isLoadingName = false;
          isLoadingLang = false;
        });

        return;
      }

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .get();

      final data = user.data();

      avatarUrl = data['urls']['image'];
      currentUserName = data['name'] ?? '';

      userState.setUserName(currentUserName);

      setState(() {
        email = userAuth.email ?? '';

        isLoadingImageURL = false;
        isLoadingName = false;
        isLoadingLang = false;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingImageURL = false;
        isLoadingName = false;
        isLoadingLang = false;
      });
    }
  }

  void getLocalLang() {
    final lang = appStorage.getLang();

    setState(() {
      selectedLang = Language.frontend(lang);
    });
  }

  void setAutoBrightness() {
    final now = DateTime.now();

    Brightness brightness = Brightness.light;

    if (now.hour < 6 || now.hour > 17) {
      brightness = Brightness.dark;
    }

    DynamicTheme.of(context).setBrightness(brightness);
    stateColors.refreshTheme(brightness);
  }

  String themeDescription() {
    return isThemeAuto
        ? 'It will be chosen accordingly to the time of the day'
        : 'Choose your theme manually';
  }

  void updateUsername() async {
    setState(() {
      isLoadingName = true;
    });

    try {
      isNameAvailable = await checkNameAvailability(newUserName);

      if (!isNameAvailable) {
        setState(() {
          isLoadingName = false;
        });

        showSnack(
          context: context,
          message: "The name $newUserName is not available",
          type: SnackType.error,
        );

        return;
      }

      final userAuth = await userState.userAuth;
      if (userAuth == null) {
        throw Error();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .update({'name': newUserName});

      setState(() {
        isLoadingName = false;
        currentUserName = newUserName;
        newUserName = '';
      });

      userState.setUserName(currentUserName);

      showSnack(
        context: context,
        message: 'Your display name has been successfully updated.',
        type: SnackType.success,
      );
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingName = false;
      });

      showSnack(
        context: context,
        message: 'Oops, there was an error: ${error.toString()}',
        type: SnackType.error,
      );
    }
  }

  void updateImageUrl({String imageName}) async {
    setState(() {
      isLoadingImageURL = true;
    });

    try {
      final userAuth = await userState.userAuth;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .update({
        'urls.image': 'local:$imageName',
      });

      setState(() {
        avatarUrl = 'local:$imageName';
        isLoadingImageURL = false;
      });

      showSnack(
        context: context,
        message: 'Your image has been successfully updated.',
        type: SnackType.success,
      );
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingImageURL = false;
      });

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

  void initNotifState() async {
    notificationsON = await PushNotifications.isActive();
    setState(() {});
  }
}
