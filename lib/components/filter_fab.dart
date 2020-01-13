import 'package:flutter/material.dart';
import 'package:memorare/types/colors.dart';
import 'package:provider/provider.dart';

class FilterFab extends StatefulWidget {
  final int order;
  final Function onOrderChanged;

  FilterFab({this.onOrderChanged, this.order});

  @override
  _FilterFabState createState() => _FilterFabState();
}

class _FilterFabState extends State<FilterFab> {
  @override
  Widget build(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context, listen: false).accent;

    return FloatingActionButton(
      onPressed: () {
        showFilterFabModal();
      },
      child: Icon(Icons.filter_list),
      backgroundColor: accent,
      foregroundColor: Colors.white,
    );
  }

void showFilterFabModal() {
  final themeColor = Provider.of<ThemeColor>(context, listen: false);
  final accent = themeColor.accent;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: Text(
                      'First to last',
                      style: TextStyle(
                        color: themeColor.blackOrWhite,
                      ),
                    ),
                    padding: EdgeInsets.all(5.0),
                    selected: widget.order == 1,
                    selectedColor: accent,
                    onSelected: (selected) {
                      if (widget.onOrderChanged != null) {
                        final newOrder = widget.order > 0 ? -1 : 1;
                        widget.onOrderChanged(newOrder);
                      }

                      Navigator.pop(context);
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: Text(
                      'Last to first',
                      style: TextStyle(
                        color: themeColor.blackOrWhite,
                      ),
                    ),
                    padding: EdgeInsets.all(5.0),
                    selected: widget.order == -1,
                    selectedColor: accent,
                    onSelected: (selected) {
                      if (widget.onOrderChanged != null) {
                        final newOrder = widget.order > 0 ? -1 : 1;
                        widget.onOrderChanged(newOrder);
                      }

                      Navigator.pop(context);
                    },
                  ),
                ),

              ],
            ),
          ],
        )
      );
    }
  );
  }
}
