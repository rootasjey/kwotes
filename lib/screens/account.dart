import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/settings_card.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/utils/push_notifications.dart';
import 'package:memorare/utils/snack.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isLoadingLang      = false;
  bool isLoadingName      = false;
  bool isLoadingImageURL  = false;
  bool isThemeAuto        = true;

  String avatarUrl      = '';
  String displayName    = '';
  String email          = '';
  String imageUrl       = '';
  String oldDisplayName = '';
  String selectedLang   = 'English';

  Brightness brightness;
  Brightness currentBrightness;
  Timer timer;

  ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    checkAuth();
    isThemeAuto = appLocalStorage.getAutoBrightness();
    currentBrightness = DynamicTheme.of(context).brightness;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget accounSettings() {
    return Observer(
      builder: (_) {
        final isUserConnected = userState.isUserConnected;

        if (isUserConnected) {
          return Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 100.0,
                child: Column(
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

                    FadeInY(
                      delay: 2.5,
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
          padding: const EdgeInsets.only(
            top: 10.0,
            bottom: 60.0,
          ),
          child: SizedBox(
            height: 200.0,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                FadeInX(
                  delay: 3.0,
                  beginX: 50.0,
                  child: SettingsCard(
                    elevation: 2.0,
                    imagePath: 'assets/images/write-email-${stateColors.iconExt}.png',
                    name: 'Email',
                    onTap: isUserConnected ?
                      () {
                        FluroRouter.router.navigateTo(context, EditEmailRoute);
                      } :
                      null,
                  ),
                ),

                FadeInX(
                  delay: 3.5,
                  beginX: 50.0,
                  child: SettingsCard(
                    elevation: 2.0,
                    imagePath: 'assets/images/lock-${stateColors.iconExt}.png',
                    name: 'Password',
                    onTap: isUserConnected ?
                      () {
                        FluroRouter.router.navigateTo(context, EditPasswordRoute);
                      } :
                      null,
                  ),
                ),

                FadeInX(
                  delay: 4.0,
                  beginX: 50.0,
                  child: SettingsCard(
                    elevation: 2.0,
                    imagePath: 'assets/images/delete-user-${stateColors.iconExt}.png',
                    name: 'Delete account',
                    onTap: isUserConnected ?
                      () {
                        FluroRouter.router.navigateTo(context, DeleteAccountRoute);
                      } :
                      null,
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget appBar() {
    return Observer(
      builder: (_) {
        return SliverAppBar(
          floating: true,
          snap: true,
          expandedHeight: 120.0,
          backgroundColor: stateColors.softBackground,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: <Widget>[
              FadeInY(
                delay: 1.0,
                beginY: 50.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: FlatButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: Duration(seconds: 2),
                        curve: Curves.easeOutQuint
                      );
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 60.0,
                      child: Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 20.0,
                top: 50.0,
                child: IconButton(
                  onPressed: () => FluroRouter.router.pop(context),
                  tooltip: 'Back',
                  icon: Icon(Icons.arrow_back),
                ),
              ),
            ],
          ),
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
          elevation: 1.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
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
        elevation: 1.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
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
                    fontSize: 25.0,
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
    return RefreshIndicator(
      onRefresh: () async {
        await checkAuth();
        return null;
      },
      child: NotificationListener<ScrollNotification>(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            appBar(),
            bodyListContent(),
          ],
        ),
      )
    );
  }

  Widget bodyListContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        accounSettings(),
        Divider(height: 30.0),
        appSettings(),
      ]),
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

    return Padding(
      padding: EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 250.0,
            child: TextFormField(
              decoration: InputDecoration(
                icon: Icon(Icons.person_outline),
                labelText: oldDisplayName.isEmpty ? 'Display name' : oldDisplayName,
              ),
              readOnly: !isUserConnected,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                setState(() {
                  displayName = value;
                });
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Display name cannot be empty.';
                }

                return null;
              },
            ),
          ),

          if (displayName.length > 0 && displayName != oldDisplayName && isUserConnected)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                onPressed: () => updateDisplayName(),
                icon: Icon(Icons.save, color: Colors.green,),
              ),
            ),
        ],
      ),
    );
  }

  Widget langSelect() {
    return DropdownButton<String>(
      elevation: 3,
      value: selectedLang,
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
    );
  }

  Widget themeSwitcher() {
    return Column(
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
                    fontSize: 25.0,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 30.0,
            ),
            child: Opacity(
              opacity: .6,
              child: Text(
                'You can let the application to switch automatically depending of the time of the day or choose manually a theme',
                style: TextStyle(
                  fontSize: 17.0,
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
                currentBrightness = DynamicTheme.of(context).brightness;
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
          SwitchListTile(
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

        getLocalLang();
        return;
      }

      final user = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .get();

      final data = user.data;
      final String imageUrl = data['urls']['image'];

      setState(() {
        oldDisplayName = userAuth.displayName ?? '';
        avatarUrl = imageUrl;
        email = userAuth.email ?? '';

        isLoadingImageURL = false;
        isLoadingName = false;
        isLoadingLang = false;
      });

      fetchLang();

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoadingImageURL = false;
        isLoadingName = false;
        isLoadingLang = false;
      });
    }
  }

  void fetchLang() async {
    final lang = appLocalStorage.getLang();

    setState(() {
      selectedLang = Language.frontend(lang);
    });
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

  void updateDisplayName() async {
    setState(() {
      isLoadingName = true;
    });

    try {
      // NOTE: Name unicity ?
      final userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.displayName = displayName;

      final userAuth = await userState.userAuth;
      if (userAuth == null) { throw Error(); }

      await userAuth.updateProfile(userUpdateInfo);

      await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .updateData({
            'name': displayName,
            'nameLowerCase': displayName.toLowerCase(),
          }
        );

      setState(() {
        isLoadingName = false;
        oldDisplayName = displayName;
        displayName = '';
      });

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
        message: 'Error while updating your display name. Please try again or contact us.',
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
        message: 'Error while updating your image URL. Please try again or contact us.',
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
