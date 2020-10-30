import 'package:flutter/material.dart';
import 'package:figstyle/screens/reference_page.dart';
import 'package:figstyle/state/colors.dart';
import 'package:figstyle/types/reference.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ReferenceRow extends StatefulWidget {
  final bool isNarrow;
  final EdgeInsets padding;
  final Function itemBuilder;
  final Function onSelected;
  final Reference reference;

  ReferenceRow({
    this.isNarrow = false,
    this.reference,
    this.itemBuilder,
    this.onSelected,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 70.0,
      vertical: 30.0,
    ),
  });

  @override
  _ReferenceRowState createState() => _ReferenceRowState();
}

class _ReferenceRowState extends State<ReferenceRow> {
  double elevation = 0.0;
  Color iconColor;
  Color iconHoverColor;

  @override
  initState() {
    super.initState();

    setState(() {
      iconHoverColor = stateColors.primary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reference = widget.reference;

    return Container(
      padding: widget.padding,
      child: Card(
        elevation: elevation,
        color: stateColors.appBackground,
        child: InkWell(
          onTap: () {
            showCupertinoModalBottomSheet(
                context: context,
                builder: (_, scrollController) => ReferencePage(
                      id: reference.id,
                      scrollController: scrollController,
                    ));
          },
          onHover: (isHover) {
            elevation = isHover ? 2.0 : 0.0;
            iconColor = isHover ? iconHoverColor : null;

            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                avatar(reference),
                title(reference),
                actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget actions() {
    return SizedBox(
      width: 50.0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PopupMenuButton<String>(
            icon: Opacity(
              opacity: .6,
              child: iconColor != null
                  ? Icon(
                      Icons.more_vert,
                      color: iconColor,
                    )
                  : Icon(Icons.more_vert),
            ),
            onSelected: widget.onSelected,
            itemBuilder: widget.itemBuilder,
          ),
        ],
      ),
    );
  }

  Widget avatar(Reference reference) {
    final isImageOk = reference.urls.image?.isNotEmpty;

    if (!isImageOk) {
      return Padding(padding: EdgeInsets.zero);
    }

    final right = widget.isNarrow ? 10.0 : 40.0;

    return Padding(
        padding: EdgeInsets.only(right: right),
        child: Card(
          elevation: 4.0,
          child: Opacity(
            opacity: elevation > 0.0 ? 1.0 : 0.8,
            child: Image.network(
              reference.urls.image,
              width: 80.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
          ),
        ));
  }

  Widget title(Reference reference) {
    var titleFontSize = widget.isNarrow ? 14.0 : 20.0;

    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            reference.name,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (reference.type?.primary?.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: widget.isNarrow
                  ? Opacity(
                      opacity: 0.6,
                      child: Text(
                        reference.type.primary,
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: null,
                      icon: Icon(Icons.filter_1),
                      label: Text(
                        reference.type.primary,
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
