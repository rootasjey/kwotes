import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkCard extends StatelessWidget {
  final String name;
  final String url;
  final String imageUrl;
  final double width;
  final double height;
  final EdgeInsets padding;

  LinkCard({
    this.name,
    this.url,
    this.imageUrl = 'assets/images/world-globe.png',
    this.width = 50.0,
    this.height = 50.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.0,
      height: 190.0,
      padding: this.padding,
      child: Card(
        elevation: 2.0,
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
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.0,
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
