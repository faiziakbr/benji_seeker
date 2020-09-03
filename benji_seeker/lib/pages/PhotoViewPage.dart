import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:dots_indicator/dots_indicator.dart' as dotIndicator;

class PhotoViewPage extends StatefulWidget {
  final List<NetworkImage> listImages;
  final int index;

  PhotoViewPage(this.listImages, this.index);

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  var _controller;
  double _currentIndex = 0;

  @override
  void initState() {
    _controller = PageController(initialPage: widget.index);
    _currentIndex = double.parse(widget.index.toString()).toDouble();
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
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
            Navigator.pop(context);
            return;
          },
          child: Stack(
            children: [
              Container(
                  width: mediaQueryData.size.width,
                  height: mediaQueryData.size.height * 1,
                  child: PhotoViewGallery.builder(
                    backgroundDecoration:
                        BoxDecoration(color: Colors.white60.withOpacity(0.4)),
                    scrollPhysics: const BouncingScrollPhysics(),
                    enableRotation: false,
                    pageController: _controller,
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                          imageProvider:
                              NetworkImage(widget.listImages[index].url),
                          initialScale: PhotoViewComputedScale.contained * 1);
                    },
                    itemCount: widget.listImages.length,
                    loadingBuilder: (context, event) => Center(
                      child: Container(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    onPageChanged: (value) {
                      setState(() {
                        _currentIndex =
                            double.parse(value.toString()).toDouble();
                      });
                    },
                  )),
              Positioned(
                bottom: mediaQueryData.size.height * 0.05,
                right: mediaQueryData.size.width * 0.3,
                left: mediaQueryData.size.width * 0.3,
                child: dotIndicator.DotsIndicator(
                  decorator:
                      dotIndicator.DotsDecorator(activeColor: Colors.black),
                  dotsCount: widget.listImages.length,
                  position: _currentIndex,
                ),
              ),
              Positioned(
                top: 8.0,
                left: 8.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.withOpacity(0.7),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
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
