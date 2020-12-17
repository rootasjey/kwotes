import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:figstyle/components/animated_app_icon.dart';
import 'package:figstyle/components/fade_in_y.dart';
import 'package:figstyle/types/enums.dart';
import 'package:figstyle/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/actions/users.dart';
import 'package:figstyle/components/page_app_bar.dart';
import 'package:figstyle/screens/signin.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/state/user.dart';
import 'package:figstyle/utils/snack.dart';
import 'package:supercharged/supercharged.dart';

class UpdateUsername extends StatefulWidget {
  final ScrollController scrollController;

  UpdateUsername({this.scrollController});

  @override
  _UpdateUsernameState createState() => _UpdateUsernameState();
}

class _UpdateUsernameState extends State<UpdateUsername> {
  bool isCheckingAuth = false;
  bool isUpdating = false;
  bool isCheckingName = false;
  bool isCompleted = false;
  bool isNameAvailable = false;

  final beginY = 10.0;
  final passwordNode = FocusNode();
  final usernameController = TextEditingController();

  String currentUsername = '';
  String nameErrorMessage = '';
  String newUserName = '';

  Timer nameTimer;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: widget.scrollController,
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.only(top: 10.0),
            sliver: appBar(),
          ),
          body(),
        ],
      ),
    );
  }

  Widget appBar() {
    final width = MediaQuery.of(context).size.width;
    double titleLeftPadding = 70.0;

    if (width < Constants.maxMobileWidth) {
      titleLeftPadding = 0.0;
    }

    return PageAppBar(
      textTitle: 'Update username',
      textSubTitle: 'Want a more personalized name?',
      titlePadding: EdgeInsets.only(
        left: titleLeftPadding,
      ),
      expandedHeight: 90.0,
      showCloseButton: true,
    );
  }

  Widget body() {
    if (isCompleted) {
      return completedView();
    }

    if (isUpdating) {
      return updatingView();
    }

    return idleView();
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Column(
          children: [
            FadeInY(beginY: 10.0, child: currentUsernameCard()),
            FadeInY(beginY: 10.0, delay: 0.4, child: usernameInput()),
            FadeInY(beginY: 10.0, delay: 0.8, child: validationButton()),
          ],
        ),
      ]),
    );
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          width: 400.0,
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Icon(
                  Icons.check_circle_outline_outlined,
                  size: 80.0,
                  color: Colors.green,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                child: Text(
                  'Your username has been successfuly updated',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Go back"),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget currentUsernameCard() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 80.0,
        bottom: 40.0,
      ),
      child: Card(
        elevation: 2.0,
        child: InkWell(
          child: Container(
            width: 300.0,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Opacity(
                          opacity: 0.6,
                          child: Icon(
                            Icons.alternate_email,
                            color: stateColors.secondary,
                          )),
                    ),
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Current email',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0),
                      child: Text(
                        currentUsername,
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
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Text(
                    'This is your current username',
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  children: <Widget>[
                    Divider(
                      color: stateColors.secondary,
                      thickness: 1.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25.0,
                      ),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          currentUsername,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25.0,
                      ),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          "You can choose a new one as long as it's uniq.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget updatingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(
          width: 400.0,
          child: Column(
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  'Updating your email...',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget usernameInput() {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 80.0,
      ),
      child: Column(
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: usernameController,
            decoration: InputDecoration(
              icon: Icon(Icons.person_outline),
              labelText: "New username",
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) async {
              setState(() {
                newUserName = value;
                isCheckingName = true;
              });

              final isWellFormatted = checkUsernameFormat(newUserName);

              if (!isWellFormatted) {
                setState(() {
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
                isNameAvailable = await checkNameAvailability(newUserName);

                if (!isNameAvailable) {
                  setState(() {
                    isCheckingName = false;
                    nameErrorMessage = 'This name is not available';
                  });

                  return;
                }

                setState(() {
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
    );
  }

  Widget validationButton() {
    return OutlinedButton.icon(
      onPressed: () => updateUsernameProcess(),
      style: OutlinedButton.styleFrom(
        primary: stateColors.primary,
      ),
      icon: Icon(Icons.check),
      label: SizedBox(
        width: 240.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                'UPDATE USERNAME',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
    });

    try {
      final userAuth = await stateUser.userAuth;

      setState(() {
        isCheckingAuth = false;
      });

      if (userAuth == null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Signin(),
          ),
        );
      }

      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userAuth.uid)
          .get();

      final data = user.data();

      setState(() {
        currentUsername = data['name'] ?? '';
      });
    } catch (error) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => Signin()));
    }
  }

  bool inputValuesOk() {
    final isWellFormatted = checkUsernameFormat(newUserName);

    if (!isWellFormatted) {
      setState(() {
        isCheckingName = false;
        nameErrorMessage = newUserName.length < 3
            ? 'Please use at least 3 characters'
            : 'Please use alpha-numerical (A-Z, 0-9) characters and underscore (_)';
      });

      return false;
    }

    return true;
  }

  void updateUsernameProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      isNameAvailable = await checkNameAvailability(newUserName);

      if (!isNameAvailable) {
        setState(() {
          isCompleted = false;
          isUpdating = false;
        });

        showSnack(
          context: context,
          message: "The name $newUserName is not available",
          type: SnackType.error,
        );

        return;
      }

      final userAuth = await stateUser.userAuth;

      if (userAuth == null) {
        isCompleted = false;
        isUpdating = false;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => Signin()),
        );

        return;
      }

      final usernameUpdateResp = await updateUsername(newUserName);

      if (!usernameUpdateResp.success) {
        final exception = usernameUpdateResp.error;

        setState(() {
          isCompleted = false;
          isUpdating = false;
        });

        showSnack(
          context: context,
          message: "[code: ${exception.code}] - ${exception.message}",
          type: SnackType.error,
        );

        return;
      }

      setState(() {
        isCompleted = true;
        isUpdating = false;
        currentUsername = newUserName;
        newUserName = '';
      });

      stateUser.setUserName(currentUsername);

      showSnack(
        context: context,
        message: 'Your username has been successfully updated.',
        type: SnackType.success,
      );

      // Navigator.of(context).pop();
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isCompleted = false;
        isUpdating = false;
      });

      showSnack(
        context: context,
        message: 'Sorry, there was an error. '
            'Can you try again later or contact us if the issue persists?',
        type: SnackType.error,
      );
    }
  }
}
