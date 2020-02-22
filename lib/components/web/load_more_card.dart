import 'package:flutter/material.dart';

class LoadMoreCard extends StatelessWidget {
  final Function onTap;
  final bool isLoading;

  LoadMoreCard({
    this.isLoading = false,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: 250.0,
        height: 250.0,
        child: Card(
          color: Color(0xFF414042),
          elevation: 0,
          child: InkWell(
            onTap: isLoading ?
            null :
            () {
              if (onTap != null) {
                onTap();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: CircularProgressIndicator(),
                    ),

                  Text(
                    isLoading ? 'Loading...' : 'Load more...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
