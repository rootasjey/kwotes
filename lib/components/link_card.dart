import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkCard extends StatelessWidget {
  final String name;
  final String url;
  final String imageUrl;
  final double width;
  final double height;

  LinkCard({
    this.name,
    this.url,
    this.imageUrl = 'assets/images/world-globe.png',
    this.width = 60.0,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.0,
      child: Card(
        child: InkWell(
          onTap: url != null ? () => launch(url) : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                imageUrl,
                height: height,
                width: width,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.0,
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
