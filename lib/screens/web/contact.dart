import 'package:flutter/material.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0),
          child: InkWell(
            onTap: () {
              FluroRouter.router.navigateTo(context, HomeRoute);
            },
            borderRadius: BorderRadius.circular(40.0),
            child: Image(
              image: AssetImage('assets/images/icon-small.png'),
              width: 70.0,
              height: 70.0,
            ),
          )
        ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 200.0,
            width: 700.0,
            child: Card(
              child: Container(
                color: Color(0xFF45D09E),
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Icon(Icons.email, color: Colors.white, size: 55.0,),
                        )
                      ],
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Opacity(
                            opacity: .5,
                            child: Text(
                              'Email',
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),

                        Text(
                          'We would love to hear from you',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                          ),
                        ),
                        Text(
                          'feedback@memorare.app',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 200.0,
            width: 700.0,
            child: Card(
              child: Container(
                color: Color(0xFF64C7FF),
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Icon(Icons.send, color: Colors.white, size: 55.0,),
                        )
                      ],
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Opacity(
                            opacity: .5,
                            child: Text(
                              'Twitter',
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),

                        Text(
                          'You can contact us on Twitter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                          ),
                        ),
                        Text(
                          '@memorareapp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ),
          ),
        ),

        Padding(padding: const EdgeInsets.only(bottom: 300.0),),
      ],
    );
  }
}
