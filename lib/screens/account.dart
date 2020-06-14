import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/actions/users.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/sliver_app_header.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/push_notifications.dart';
import 'package:memorare/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isLoadingLang      = false;
  bool isLoadingName      = false;
  bool isLoadingImageURL  = false;
  bool isThemeAuto        = true;

  bool isNameAvailable = false;
  bool isCheckingName = false;
  String nameErrorMessage = '';
  Timer nameTimer;

  String avatarUrl      = '';
  String newUserName    = '';
  String email          = '';
  String imageUrl       = '';
  String currentUserName = '';
  String selectedLang   = 'English';

  Brightness brightness;
  Brightness currentBrightness;
  Timer timer;

  ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    getLocalLang();
    checkAuth();

    isThemeAuto = appLocalStorage.getAutoBrightness();
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
        )
      ),
    );
  }

  Widget accountSettings() {
    return Observer(
      builder: (_) {
        final isUserConnected = userState.isUserConnected;

        if (isUserConnected) {
          return Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 100.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FadeInY(
                      delay: 1.5,
                      beginY: 50.0,
                      child: avatar(isUserConnected),
                    ),

                    FadeInY(
                      delay: 2.0,
                      beginY: 50.0,
                      child: inputDisplayName(isUserConnected),
                    ),

                    Padding(padding: const EdgeInsets.only(top: 20.0)),

                    FadeInY(
                      delay: 2.5,
                      beginY: 50.0,
                      child: emailButton(),
                    ),

                    FadeInY(
                      delay: 3.0,
                      beginY: 50.0,
                      child: langSelect(),
                    ),
                  ],
                ),
              ),

              accountActions(isUserConnected),
            ],
          );
        }

        return Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                FadeInY(
                  delay: 2.5,
                  beginY: 50.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 45.0),
                    child: langSelect(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget accountActions(bool isUserConnected) {
    return Observer(
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Wrap(
            spacing: 15.0,
            children: <Widget>[
              FadeInX(
                delay: 3.0,
                beginX: 50.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      width: 90.0,
                      height: 90.0,
                      child: Card(
                        elevation: 4.0,
                        child: InkWell(
                          onTap: () {
                            FluroRouter.router.navigateTo(context, EditPasswordRoute);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              'assets/images/lock-${stateColors.iconExt}.png',
                              width: 30.0,
                              height: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Opacity(
                      opacity: .8,
                      child: Text(
                        'Update password',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              FadeInX(
                delay: 3.5,
                beginX: 50.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      width: 90.0,
                      height: 90.0,
                      child: Card(
                        elevation: 4.0,
                        child: InkWell(
                          onTap: () {
                            FluroRouter.router.navigateTo(context, DeleteAccountRoute);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              'assets/images/delete-user-${stateColors.iconExt}.png',
                              width: 30.0,
                              height: 30.0,
                            ),
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
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget appBar() {
    return SliverAppHeader(
      title: 'Settings',
      subTitle: 'View & update your account settings',
      onScrollToTop: () {
        _scrollController.animateTo(
          0,
          duration: Duration(seconds: 2),
          curve: Curves.easeOutQuint
        );
      },
    );
  }

  Widget appSettings() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          themeSwitcher(),
          backgroundTasks(),
          Padding(padding: const EdgeInsets.only(bottom: 100.0)),
        ],
      ),
    );
  }

  Widget avatar(bool isUserConnected) {
    if (isLoadingImageURL) {
      return Padding(
        padding: const EdgeInsets.only(
          top: 80.0,
          bottom: 60.0,
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
        top: 80.0,
        bottom: 60.0,
      ),
      child: Material(
        elevation: 4.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: avatarUrl.isEmpty ?
              Image.asset('assets/images/user-${stateColors.iconExt}.png', width: 80.0) :
              Image.asset(path, width: 80.0),
          ),
          onTap: isUserConnected ?
            () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return showAvatarDialog();
                },
              );
            } :
            null,
        ),
      ),
    );
  }

  Widget backgroundTasks() {
    return Column(
      children: <Widget>[
        FadeInY(
          delay: 5.0,
          beginY: 50.0,
          child: Row(
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
        ),

        Observer(
          builder: (context) {
            return FadeInY(
              delay: 6.0,
              beginY: 50.0,
              child: SwitchListTile(
                onChanged: (bool value) {
                  userState.setQuotidianNotifState(value);

                  timer?.cancel();
                  timer = Timer(
                    Duration(seconds: 1),
                    () => toggleBackgroundTask(value)
                  );
                },
                value: userState.isQuotidianNotifActive,
                title: Text('Daily quote'),
                secondary: userState.isQuotidianNotifActive ?
                  Icon(Icons.notifications_active):
                  Icon(Icons.notifications_off),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget body() {
    return SliverList(
      delegate: SliverChildListDelegate([
        accountSettings(),
        Divider(height: 30.0),
        appSettings(),
      ]),
    );
  }

  Widget emailButton() {
    return FlatButton(
      onPressed: () {
        FluroRouter.router.navigateTo(context, EditEmailRoute);
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
          }
        );
      },
      child: SizedBox(
        width: 250.0,
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
    return SizedBox(
      width: 130.0,
      height: 130.0,
      child: Card(
        elevation: 2.0,
        shape: avatarUrl.replaceFirst('local:', '') == imageName ?
          RoundedRectangleBorder(
            side: BorderSide(
              color: stateColors.primary,
            )
          ) :
          RoundedRectangleBorder(),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            updateImageUrl(imageName: imageName);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/$imageName-${stateColors.iconExt}.png'),
          ),
        ),
      ),
    );
  }

  Widget inputDisplayName(bool isUserConnected) {
    if (isLoadingName) {
      return SizedBox(
        height: 200.0,
        width: 300.0,
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),

            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'Updating your display name...'
              ),
            )
          ],
        ),
      );
    }

    return FlatButton(
      onPressed: () {
        showUpdateNameDialog();
      },
      child: SizedBox(
        width: 250.0,
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
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Divider(),
                    Padding(padding: const EdgeInsets.only(top: 8.0)),

                    TextFormField(
                      autofocus: true,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person_outline),
                        labelText: currentUserName.isEmpty ? 'Display name' : currentUserName,
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) async {
                        childSetState(() {
                          newUserName = value;
                          isCheckingName = true;
                        });

                        if (nameTimer != null) {
                          nameTimer.cancel();
                          nameTimer = null;
                        }

                        nameTimer = Timer(
                          1.seconds,
                          () async {
                            isNameAvailable = await checkNameAvailability(newUserName);

                            if (!isNameAvailable) {
                              childSetState(() {
                                isCheckingName = false;
                                nameErrorMessage = 'This name is not available';
                              });

                              return;
                            }

                            childSetState(() {
                              isCheckingName = false;
                              nameErrorMessage = '';
                            });
                          }
                        );
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
                        padding: const EdgeInsets.only(left: 40.0, top: 5.0),
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
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    childSetState(() {
                      isCheckingName = false;
                      nameErrorMessage = '';
                    });

                    FluroRouter.router.pop(context);
                  },
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: stateColors.foreground.withOpacity(.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: isNameAvailable ? () {
                    FluroRouter.router.pop(context);
                    updateUserName();
                  } : null,
                  child: Text(
                    'UPDATE',
                    style: TextStyle(
                      color: stateColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    );
  }

  Widget langSelect() {
    return Container(
      width: 250.0,
      padding: const EdgeInsets.only(top: 20.0),
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
                  'Language',
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 35.0),
            child: Row(
              children: <Widget>[
                DropdownButton<String>(
                  elevation: 3,
                  value: selectedLang,
                  isDense: true,
                  style: TextStyle(
                    color: stateColors.foreground,
                    fontFamily: 'Comfortaa',
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      selectedLang = newValue;
                    });

                    updateLang();
                  },
                  items: ['English', 'Français']
                    .map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value,)
                      );
                    })
                    .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget themeSwitcher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FadeInY(
          delay: 2.0,
          beginY: 50.0,
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
          beginY: 50.0,
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
          beginY: 50.0,
          child: SwitchListTile(
            title: Text('Automatic theme'),
            secondary: const Icon(Icons.autorenew),
            value: isThemeAuto,
            onChanged: (newValue) {
              if (!newValue) {
                currentBrightness = appLocalStorage.getBrightness();
                DynamicTheme.of(context).setBrightness(currentBrightness);
                stateColors.refreshTheme(currentBrightness);
              }

              appLocalStorage.setAutoBrightness(newValue);

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
            delay: 5.0,
            beginY: 50.0,
            child: SwitchListTile(
              title: Text('Lights'),
              secondary: const Icon(Icons.lightbulb_outline),
              value: currentBrightness == Brightness.light,
              onChanged: (newValue) {
                currentBrightness = newValue ?
                    Brightness.light : Brightness.dark;

                DynamicTheme.of(context).setBrightness(currentBrightness);
                stateColors.refreshTheme(currentBrightness);

                appLocalStorage.setBrightness(currentBrightness);

                setState(() {});
              },
            ),
          ),
      ],
    );
  }

  AlertDialog showAvatarDialog() {
    return AlertDialog(
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'Cancel',
            ),
          ),
        ),
      ],
      content: SizedBox(
        height: 260.0,
        child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 40.0,
                  ),
                  child: Opacity(
                    opacity: .6,
                    child: SizedBox(
                      width: 300.0,
                      child: Text(
                        'You can choose another profile picture',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    )
                  ),
                ),
              ),

              SizedBox(
                height: 150.0,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  children: <Widget>[
                    FadeInX(child: ppCard(imageName: 'boy'), delay: 1, beginX: 100.0,),
                    FadeInX(child: ppCard(imageName: 'employee'), delay: 1.2, beginX: 100.0,),
                    FadeInX(child: ppCard(imageName: 'lady'), delay: 1.3, beginX: 100.0,),
                    FadeInX(child: ppCard(imageName: 'user'), delay: 1.4, beginX: 100.0,),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      )
    );
  }

  void toggleBackgroundTask(bool isActive) async {
    final lang = appLocalStorage.getLang();

    final success = isActive ?
      await PushNotifications.subMobileQuotidians(lang: lang) :
      await PushNotifications.unsubMobileQuotidians(lang: lang);

    if (!success) {
      userState.setQuotidianNotifState(!userState.isQuotidianNotifActive);

      showSnack(
        context: context,
        message: 'Sorry, there was an issue while updating your preferences. Try again in a moment.',
        type: SnackType.error,
      );
    }
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

      final user = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .get();

      final data = user.data;

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
    final lang = appLocalStorage.getLang();

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
    return isThemeAuto ?
      'It will be chosen accordingly to the time of the day' :
      'Choose your theme manually';
  }

  void updateUserName() async {
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
      if (userAuth == null) { throw Error(); }

      await Firestore.instance
      .collection('users')
      .document(userAuth.uid)
      .updateData({'name': newUserName});

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

      await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .updateData({
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

    if (userState.isQuotidianNotifActive) {
      final lang = appLocalStorage.getLang();
      await PushNotifications.updateQuotidiansSubLang(lang: lang);
    }

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
