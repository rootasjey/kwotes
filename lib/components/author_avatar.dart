import 'package:animations/animations.dart';
import 'package:figstyle/components/image_hero.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class AuthorAvatar extends StatefulWidget {
  final String imageUrl;

  const AuthorAvatar({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  @override
  _AuthorAvatarState createState() => _AuthorAvatarState();
}

class _AuthorAvatarState extends State<AuthorAvatar>
    with TickerProviderStateMixin {
  Animation<double> scaleAnimation;
  AnimationController scaleAnimationController;

  double avatarSize = 150.0;

  @override
  initState() {
    super.initState();
    scaleAnimationController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: 500.milliseconds,
      vsync: this,
    );

    scaleAnimation = CurvedAnimation(
      parent: scaleAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  dispose() {
    scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrl;
    final isImageUrlOk = imageUrl != null && imageUrl.isNotEmpty;

    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0.0,
      closedBuilder: (_, openContainer) {
        return ScaleTransition(
          scale: scaleAnimation,
          child: Material(
            elevation: 3.0,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              child: Ink.image(
                image: isImageUrlOk
                    ? NetworkImage(imageUrl)
                    : AssetImage('assets/images/user-m.png'),
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: openContainer,
                  onHover: (isHover) {
                    if (isHover) {
                      scaleAnimationController.forward();
                      return;
                    }

                    scaleAnimationController.reverse();
                  },
                ),
              ),
            ),
          ),
        );
      },
      openBuilder: (context, callback) {
        return ImageHero(
          imageProvider: isImageUrlOk
              ? NetworkImage(
                  imageUrl,
                )
              : AssetImage('assets/images/user-m.png'),
        );
      },
    );
  }
}
