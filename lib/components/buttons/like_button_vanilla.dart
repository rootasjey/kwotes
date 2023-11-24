import "package:flutter/material.dart";
import "package:rive/rive.dart";

class LikeButtonVanilla extends StatefulWidget {
  /// A animated heart shapped button (with Rive).
  /// This has been made a standalone component
  /// because of the animation ceremony (e.g. needs a controller).
  /// Doesn't have an overlay icon for to adjust foreground color.
  /// See also:
  /// - [LikeButton]
  const LikeButtonVanilla({
    super.key,
    this.initialLiked = false,
    this.size = const Size(42.0, 42.0),
    this.tooltip = "",
    this.margin = EdgeInsets.zero,
    this.color,
    this.onPressed,
  });

  /// Initial liked state.
  /// Set to true if you want the animation to start in liked state.
  /// Default to false.
  final bool initialLiked;

  /// Color of the button.
  final Color? color;

  /// Margin around the button.
  final EdgeInsets margin;

  /// Callback fired when the button is pressed.
  final void Function()? onPressed;

  /// Size of the button.
  final Size size;

  /// Tooltip text.
  final String tooltip;

  @override
  State<LikeButtonVanilla> createState() => _LikeButtonVanillaState();
}

class _LikeButtonVanillaState extends State<LikeButtonVanilla> {
  SMIInput<bool>? _like;

  @override
  void dispose() {
    _like?.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _like?.value = widget.initialLiked;

    return Container(
      width: widget.size.width,
      height: widget.size.height,
      padding: widget.margin,
      child: Tooltip(
        message: widget.tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(28.0),
          onTap: () {
            final bool newValue = _like != null ? !_like!.value : true;
            _like?.change(newValue);
            widget.onPressed?.call();
          },
          child: Stack(
            children: [
              RiveAnimation.asset(
                "assets/animations/like-button.riv",
                fit: BoxFit.cover,
                onInit: onInit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onInit(Artboard artboard) {
    final StateMachineController? controller =
        StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );

    if (controller == null) {
      return;
    }

    artboard.addController(controller);
    _like = controller.findInput<bool>("Like");
    _like?.change(widget.initialLiked);
  }
}
