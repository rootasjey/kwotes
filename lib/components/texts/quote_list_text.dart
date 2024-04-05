import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:kwotes/globals/constants.dart";
import "package:kwotes/globals/utils.dart";
import "package:kwotes/types/quote_list.dart";
import "package:lottie/lottie.dart";

/// A component representing a list of quotes.
/// It displays the list's name and description.
class QuoteListText extends StatefulWidget {
  const QuoteListText({
    super.key,
    required this.quoteList,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.isEditing = false,
    this.isDeleting = false,
    this.tiny = false,
    this.onCancelEditMode,
    this.onSaveChanges,
    this.onConfirmDelete,
    this.onCancelDelete,
  });

  /// Show text input if true.
  final bool isEditing;

  /// Reduce font size if this true.
  final bool tiny;

  /// Show confirm delete button if true.
  final bool isDeleting;

  /// Space around this widget.
  final EdgeInsets margin;

  /// Quote to display.
  final QuoteList quoteList;

  /// Callback fired when a list of quotes is tapped.
  final void Function(QuoteList quoteList)? onTap;

  /// Callback to exit edit list mode.
  final void Function()? onCancelEditMode;

  /// Callback to confirm list deletion.
  final void Function(QuoteList quoteList)? onConfirmDelete;

  /// Callback to exit delete list confirmation.
  final void Function(QuoteList quoteList)? onCancelDelete;

  /// Callback to save list changes.
  final void Function(String name, String description)? onSaveChanges;

  @override
  State<QuoteListText> createState() => _QuoteListTextState();
}

class _QuoteListTextState extends State<QuoteListText> {
  /// Text shadow color.
  Color _textShadowColor = Colors.transparent;

  /// Text field controller.
  final TextEditingController _nameController = TextEditingController();

  String _prevName = "";

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.quoteList.name;
    _prevName = _nameController.text;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QuoteList quoteList = widget.quoteList;
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyMedium?.color;

    if (widget.isEditing) {
      return Padding(
        padding: widget.margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              controller: _nameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              onChanged: onNameChanged,
              onSubmitted: (String name) =>
                  widget.onSaveChanges?.call(name, ""),
              textInputAction: TextInputAction.go,
              style: Utils.calligraphy.body(
                textStyle: TextStyle(
                  fontSize: widget.tiny ? 36.0 : 54.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
              decoration: InputDecoration(
                hintText: widget.quoteList.name,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (widget.quoteList.id.isNotEmpty)
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.start,
                children: [
                  TextButton(
                    onPressed: widget.onCancelEditMode,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 6.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      backgroundColor: Colors.black12,
                      foregroundColor:
                          Theme.of(context).textTheme.bodyMedium?.color,
                      textStyle: Utils.calligraphy.body4(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    child: Text(
                      "cancel".tr(),
                    ),
                  ),
                  TextButton(
                    onPressed: _nameController.text.isEmpty
                        ? null
                        : () => widget.onSaveChanges
                            ?.call(_nameController.text, ""),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 6.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      backgroundColor: _nameController.text.isEmpty
                          ? null
                          : Constants.colors.lists.withOpacity(0.1),
                      foregroundColor: Constants.colors.lists,
                      textStyle: Utils.calligraphy.body4(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    child: Text(
                      "list.save.name".tr(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: widget.margin,
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: widget.onTap != null
            ? () => widget.onTap?.call(widget.quoteList)
            : null,
        onHover: (bool isHover) {
          if (isHover) {
            setState(() {
              _textShadowColor = Constants.colors.lists;
            });

            return;
          }

          setState(() {
            _textShadowColor = Colors.transparent;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: quoteList.id,
              child: Material(
                color: Colors.transparent,
                child: Text(
                  quoteList.name,
                  style: Utils.calligraphy.body(
                    textStyle: TextStyle(
                      fontSize: widget.tiny ? 36.0 : 54.0,
                      fontWeight: FontWeight.w200,
                      color: quoteList.id.isNotEmpty
                          ? foregroundColor?.withOpacity(0.8)
                          : foregroundColor?.withOpacity(0.4),
                      shadows: [
                        Shadow(
                          blurRadius: 0.5,
                          offset: const Offset(-1.0, 1.0),
                          color: _textShadowColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (quoteList.id.isEmpty)
              Row(
                children: [
                  Text(
                    "${"list.create.ing".tr()}...",
                    style: Utils.calligraphy.body4(
                      textStyle: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: foregroundColor?.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Lottie.asset(
                    "assets/animations/dots-loading.json",
                    width: 124.0,
                    // height: 54.0,
                  ),
                ],
              ),

            if (widget.isDeleting)
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.start,
                children: [
                  TextButton(
                    onPressed: widget.onCancelDelete != null
                        ? () => widget.onCancelDelete?.call(widget.quoteList)
                        : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 6.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      backgroundColor: Colors.black12,
                      foregroundColor:
                          Theme.of(context).textTheme.bodyMedium?.color,
                      textStyle: Utils.calligraphy.body4(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    child: Text(
                      "cancel".tr(),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onConfirmDelete != null
                        ? () => widget.onConfirmDelete?.call(widget.quoteList)
                        : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 6.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      backgroundColor: Constants.colors.delete.withOpacity(0.1),
                      foregroundColor: Constants.colors.delete,
                      textStyle: Utils.calligraphy.body4(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    child: Text(
                      "list.delete.name".tr(),
                    ),
                  ),
                ],
              ),
            // if (quoteList.description.isNotEmpty)
            //   Text(
            //     quoteList.description,
            //     style: Utils.calligraphy.body2(
            //       textStyle: TextStyle(
            //         fontSize: 14.0,
            //         fontWeight: FontWeight.w400,
            //         color: foregroundColor?.withOpacity(0.3),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  /// Callback when list's name has changed.
  void onNameChanged(String name) {
    if (_prevName.isNotEmpty && name.isEmpty) {
      setState(() {
        _prevName = name;
      });
      return;
    }

    if (_prevName.isEmpty && name.isNotEmpty) {
      setState(() {
        _prevName = name;
      });
      return;
    }

    _prevName = name;
  }
}
