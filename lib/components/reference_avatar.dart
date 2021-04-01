import 'package:animations/animations.dart';
import 'package:fig_style/components/image_hero.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class ReferenceAvatar extends StatefulWidget {
  final String imageUrl;

  const ReferenceAvatar({Key key, @required this.imageUrl}) : super(key: key);

  @override
  _ReferenceAvatarState createState() => _ReferenceAvatarState();
}

class _ReferenceAvatarState extends State<ReferenceAvatar>
    with TickerProviderStateMixin {
  Animation<double> scaleAnimation;
  AnimationController scaleAnimationController;

  double avatarHeight = 250.0;
  double avatarWidth = 200.0;

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
      closedBuilder: (context, openContainer) {
        return ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            width: avatarWidth,
            height: avatarHeight,
            child: Card(
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
              child: Ink.image(
                height: avatarHeight,
                width: avatarWidth,
                fit: BoxFit.cover,
                image: isImageUrlOk
                    ? NetworkImage(
                        imageUrl,
                      )
                    : AssetImage('assets/images/reference.png'),
                child: InkWell(
                  onTap: openContainer,
                  onHover: (isHover) {
                    if (isHover) {
                      scaleAnimationController.forward();
                      return;
                    }

                    scaleAnimationController.reverse();
                    return;
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
              : AssetImage('assets/images/reference.png'),
        );
      },
    );
  }
}
