import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/components/web/fade_in_x.dart';
import 'package:memorare/components/web/fade_in_y.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/components/web/settings_card.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/app_localstorage.dart';
import 'package:memorare/utils/language.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/utils/snack.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isCheckingAuth     = false;
  bool isLoadingLang      = false;
  bool isLoadingImageURL  = false;
  bool isThemeAuto        = true;

  String avatarUrl      = '';
  String displayName    = '';
  String email          = '';
  String imageUrl       = '';
  String oldDisplayName = '';
  String selectedLang   = 'English';

  Brightness currentBrightness;

  @override
  void initState() {
    super.initState();
    checkAuth();

    isThemeAuto = appLocalStorage.getAutoBrightness();
    currentBrightness = DynamicTheme.of(context).brightness;
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingAuth) {
      return FullPageLoading();
    }

    return Container(
      child: Column(
        children: <Widget>[
          NavBackHeader(),

          FadeInY(
            beginY: 50.0,
            child: headerTitle(),
          ),

          FadeInY(
            delay: 1.0,
            beginY: 50.0,
            child: headerSubtitle(),
          ),

          FadeInY(
            delay: 1.5,
            beginY: 50.0,
            child: avatar(),
          ),

          FadeInY(
            delay: 2.0,
            beginY: 50.0,
            child: inputDisplayName(),
          ),

          FadeInY(
            delay: 2.5,
            beginY: 50.0,
            child: langSelect(),
          ),

          accountActions(),

          themeSwitcher(),

          NavBackFooter(),
        ],
      ),
    );
  }

  Widget accountActions() {
    return Observer(
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 120.0),
          child: SizedBox(
            width: 800.0,
            child: Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                FadeInX(
                  delay: 3.0,
                  beginX: 50.0,
                  child: SettingsCard(
                    imagePath: 'assets/images/write-email-${stateColors.iconExt}.png',
                    name: 'Email',
                    onTap: () {
                      FluroRouter.router.navigateTo(context, EditEmailRoute);
                    },
                  ),
                ),

                FadeInX(
                  delay: 3.5,
                  beginX: 50.0,
                  child: SettingsCard(
                    imagePath: 'assets/images/lock-${stateColors.iconExt}.png',
                    name: 'Password',
                    onTap: () {
                      FluroRouter.router.navigateTo(context, EditPasswordRoute);
                    },
                  ),
                ),

                FadeInX(
                  delay: 4.0,
                  beginX: 50.0,
                  child: SettingsCard(
                    imagePath: 'assets/images/delete-user-${stateColors.iconExt}.png',
                    name: 'Delete account',
                    onTap: () {
                      FluroRouter.router.navigateTo(context, DeleteAccountRoute);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget avatar() {
    if (isLoadingImageURL) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
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
      padding: const EdgeInsets.only(bottom: 60.0),
      child: Material(
        elevation: 1.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: avatarUrl.isEmpty ?
              Image.asset('assets/images/user-${stateColors.iconExt}.png', width: 100.0) :
              Image.asset(path, width: 100.0),
          ),
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return showAvatarDialog();
              },
            );
          },
        ),
      ),
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
        height: 200.0,
        width: 500.0,
        child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
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

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Wrap(
                    spacing: 20.0,
                    runSpacing: 20.0,
                    children: <Widget>[
                      FadeInX(child: ppCard(imageName: 'boy'), delay: 1, beginX: 100.0,),
                      FadeInX(child: ppCard(imageName: 'employee'), delay: 1.2, beginX: 100.0,),
                      FadeInX(child: ppCard(imageName: 'lady'), delay: 1.3, beginX: 100.0,),
                      FadeInX(child: ppCard(imageName: 'user'), delay: 1.4, beginX: 100.0,),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: 5.0,
            right: 5.0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
            ),
          ),
        ],
      ),
      )
    );
  }

  Widget ppCard({String imageName}) {
    return SizedBox(
      width: 80.0,
      height: 80.0,
      child: Card(
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

  Widget headerSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 120.0),
      child: Opacity(
        opacity: .7,
        child: Text(
          'You can update your account settings here.',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      )
    );
  }

  Widget headerTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        'Account Settings',
        style: TextStyle(
          fontSize: 30.0,
        ),
      ),
    );
  }

  Widget inputDisplayName() {
    if (isLoadingLang) {
      return SizedBox(
        height: 200.0,
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

    return Container(
      padding: EdgeInsets.only(bottom: 40.0),
      width: 400.0,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 330.0,
            child: TextFormField(
              decoration: InputDecoration(
                icon: Icon(Icons.person_outline),
                labelText: oldDisplayName.isEmpty ? 'Display name' : oldDisplayName,
              ),
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

          if (displayName.length > 0 && displayName != oldDisplayName)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                onPressed: () {
                  updateDisplayName();
                },
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
    return Container(
      width: 450.0,
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        children: <Widget>[
          Text(
            'Theme',
            style: TextStyle(
              fontSize: 25.0,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
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

          SwitchListTile(
            title: Text('Automatic theme'),
            secondary: const Icon(Icons.autorenew),
            value: isThemeAuto,
            onChanged: (newValue) {
              if (!newValue) {
                currentBrightness = DynamicTheme.of(context).brightness;
              }

              appLocalStorage.saveAutoBrightness(newValue);

              if (newValue) {
                setAutoBrightness();
              }

              setState(() {
                isThemeAuto = newValue;
              });
            },
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

                appLocalStorage.saveBrightness(currentBrightness);

                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = await userState.userAuth;

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
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
      });

      fetchLang();

    } catch (error) {
      debugPrint(error.toString());
      isCheckingAuth = false;
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  void fetchLang() async {
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
      isLoadingLang = true;
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
        isLoadingLang = false;
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
        isLoadingLang = false;
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
    final lang = Language.backend(selectedLang);
    Language.setLang(lang);

    showSnack(
      context: context,
      message: 'Your language has been successfully updated.',
      type: SnackType.success,
    );
  }
}
