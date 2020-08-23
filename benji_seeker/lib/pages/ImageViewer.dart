import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'ZoomableImage.dart';

class ImageViewer extends StatefulWidget {
  final List<NetworkImage> listImages;
  final int index;

  ImageViewer(this.listImages, this.index);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int _current = 0;

  @override
  void initState() {
    _current = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white60.withOpacity(0.95),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
                width: mediaQueryData.size.width,
                height: mediaQueryData.size.height * 0.8,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: mediaQueryData.size.width,
                      height: mediaQueryData.size.height * 0.75,
                      child: CarouselSlider(
                        options: CarouselOptions(
                            autoPlay: false,
                            enableInfiniteScroll: false,
                            aspectRatio: 0.222,
                            initialPage: widget.index,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            }),
                        items: widget.listImages.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ZoomableImage(i.url)));
                                },
                                child:
                                Container(child: Image.network('${i.url}')),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.listImages.map((url) {
                        int index = widget.listImages.indexOf(url);
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current == index
                                ? Color.fromRGBO(0, 0, 0, 0.9)
                                : Color.fromRGBO(0, 0, 0, 0.4),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ))
//            Container(
//              width: mediaQueryData.size.width,
//              height: mediaQueryData.size.height * 0.8,
//              child: Carousel(
//                autoplay: false,
//                dotSize: 6.0,
//                boxFit: BoxFit.contain,
//                dotPosition: DotPosition.bottomCenter,
//                dotSpacing: 15.0,
//                dotIncreasedColor: separatorColor,
//                dotColor: unselectedDotColor,
//                indicatorBgPadding: 5.0,
//                dotBgColor: Colors.transparent,
//                images: widget._listImages,
//
//                onImageTap: (index) {
//                  Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) =>
//                              ZoomableImage(widget._listImages[index].url)));
//                },
//              ),
//            ),
          ],
        ),
      ),
    );
  }
}
