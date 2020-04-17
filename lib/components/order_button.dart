import 'package:flutter/material.dart';
import 'package:memorare/state/colors.dart';

class OrderButton extends StatefulWidget {
  final bool descending;
  final Function onOrderChanged;

  OrderButton({
    this.descending,
    this.onOrderChanged,
  });

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
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
              Text('Order'),

              Wrap(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
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
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
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
