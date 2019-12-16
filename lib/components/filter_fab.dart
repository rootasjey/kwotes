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
    return FloatingActionButton(
      onPressed: () {
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
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 100.0,
                        height: 70.0,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);

                            if (widget.onOrderChanged != null) {
                              final newOrder = widget.order > 0 ? -1 : 1;
                              widget.onOrderChanged(newOrder);
                            }
                           },
                          child: Column(
                            children: <Widget>[
                              Image(
                                width: 40.0,
                                height: 40.0,
                                image: widget.order > 0 ?
                                AssetImage('assets/images/sort_up.png') :
                                AssetImage('assets/images/sort_down.png'),
                                color: Colors.black54,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10.0),
                                child: Text(
                                  widget.order > 0 ? 'Last to First' : 'First to Last',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ),
                    ],
                  ),
                ],
              )
            );
          }
        );
      },
      child: Icon(Icons.filter_list),
      backgroundColor: Provider.of<ThemeColor>(context).accent,
    );
  }
}
