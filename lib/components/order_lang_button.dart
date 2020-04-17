import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';

class OrderLangButton extends StatefulWidget {
  final bool descending;
  final String lang;
  final Function onOrderChanged;
  final Function onLangChanged;

  OrderLangButton({
    this.descending,
    this.lang,
    this.onLangChanged,
    this.onOrderChanged,
  });

  @override
  _OrderLangButtonState createState() => _OrderLangButtonState();
}

class _OrderLangButtonState extends State<OrderLangButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showFilterFabModal();
      },
      icon: Icon(
        Icons.filter_list,
      ),
    );
  }

  void showFilterFabModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              orderSection(),
              langSection(),
            ],
          )
        );
      }
    );
  }

  Widget langSection() {
    return Column(
      children: <Widget>[
        Divider(height: 30.0,),

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text('Language'),
        ),

        Wrap(
          spacing: 20.0,
          children: <Widget>[
            ChoiceChip(
                label: Text(
                  'English',
                  style: TextStyle(
                    color: widget.lang == 'en' ?
                      Colors.white :
                      stateColors.foreground,
                  ),
                ),
                padding: EdgeInsets.all(5.0),
                selected: widget.lang == 'en',
                selectedColor: stateColors.primary,
                onSelected: (selected) {
                  if (widget.onLangChanged != null) {
                    widget.onLangChanged('en');
                  }

                  Navigator.pop(context);
                },
              ),

            ChoiceChip(
              label: Text(
                'Français',
                style: TextStyle(
                  color: widget.lang == 'fr' ?
                    Colors.white :
                    stateColors.foreground,
                ),
              ),
              padding: EdgeInsets.all(5.0),
              selected: widget.lang == 'fr',
              selectedColor: stateColors.primary,
              onSelected: (selected) {
                if (widget.onLangChanged != null) {
                  widget.onLangChanged('fr');
                }

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget orderSection() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text('Order'),
        ),

        Wrap(
          spacing: 20.0,
          children: <Widget>[
            ChoiceChip(
              label: Text(
                'First added',
                style: TextStyle(
                  color: !widget.descending ?
                    Colors.white :
                    stateColors.foreground,
                ),
              ),
              padding: EdgeInsets.all(5.0),
              selected: !widget.descending,
              selectedColor: stateColors.primary,
              onSelected: (selected) {
                if (widget.onOrderChanged != null) {
                  final newOrder = !widget.descending;
                  widget.onOrderChanged(newOrder);
                }

                Navigator.pop(context);
              },
            ),

            ChoiceChip(
              label: Text(
                'Last added',
                style: TextStyle(
                  color: widget.descending ?
                    Colors.white :
                    stateColors.foreground,
                ),
              ),
              padding: EdgeInsets.all(5.0),
              selected: widget.descending,
              selectedColor: stateColors.primary,
              onSelected: (selected) {
                if (widget.onOrderChanged != null) {
                  final newOrder = !widget.descending;
                  widget.onOrderChanged(newOrder);
                }

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
