import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ExpandedPhoto extends StatefulWidget {
  final String imageURL;

  ExpandedPhoto({this.imageURL});
  @override
  _ExpandedPhotoState createState() => _ExpandedPhotoState();
}

class _ExpandedPhotoState extends State<ExpandedPhoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            backgroundDecoration: BoxDecoration(color: Colors.black),
            // imageProvider: NetworkImage(widget.imageURL),
            imageProvider: CachedNetworkImageProvider(widget.imageURL),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 60.0),
            child: ClipOval(
              child: Material(
                color: Colors.black,
                child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
