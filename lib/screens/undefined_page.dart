import 'package:flutter/material.dart';
import 'package:figstyle/components/app_icon.dart';
import 'package:figstyle/screens/home/home.dart';

class UndefinedPage extends StatefulWidget {
  final String name;

  UndefinedPage({this.name});

  @override
  _UndefinedPageState createState() => _UndefinedPageState();
}

class _UndefinedPageState extends State<UndefinedPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppIcon(),
        Text(
          '404',
          style: TextStyle(
            fontSize: 80.0,
          ),
        ),
        Opacity(
          opacity: .6,
          child: Text('Route for "${widget.name}" is not defined.'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Image(
            image: AssetImage('assets/images/page-not-found-4.png'),
            width: 350.0,
            height: 350.0,
          ),
        ),
        Padding(padding: EdgeInsets.only(bottom: 100.0)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Column(
                    children: <Widget>[
                      Opacity(
                        opacity: .8,
                        child: Text(
                          // 'It is by getting lost that we learn.',
                          'When we are lost, what matters is to find our way back.',
                          style: TextStyle(
                            fontSize: 30.0,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100.0,
                        child: Divider(
                          height: 50.0,
                          thickness: 1.0,
                        ),
                      ),
                      Opacity(
                        opacity: .6,
                        child: Text('Outofcontext'),
                      ),
                    ],
                  ),
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: FlatButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => Home()));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Go home'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 300.0),
        ),
      ],
    );
  }
}
