import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class ZoomableImage extends StatefulWidget {
  final String image;

  ZoomableImage(this.image);

  @override
  _ZoomableImageState createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
          Navigator.pop(context);
          return;
        },
        child: Material(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Container(
                  height: mediaQueryData.size.height * 0.85,
                  child: PhotoView(
                    enableRotation: false,
                    imageProvider: NetworkImage(widget.image),
                  )),
              Positioned(
                top: 8.0,
                right: 8.0,
                child: IconButton(
                  onPressed: () {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                    ]);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}
