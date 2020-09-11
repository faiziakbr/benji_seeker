import 'package:benji_seeker/constants/MyColors.dart';
import 'package:benji_seeker/custom_texts/MontserratText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ItemOrder extends StatelessWidget {
  final MediaQueryData mediaQueryData;
  final String text;
  final String image;
  final String id;
  final Function onClick;

  ItemOrder(this.mediaQueryData, this.text, this.image, this.id, this.onClick);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return InkWell(
      onTap: () => onClick(context, id, text),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Card(
          margin: EdgeInsets.only(bottom: 15.0),
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: mediaQueryData.size.width * 0.16,
                  height: mediaQueryData.size.width * 0.13,
                  child: SvgPicture.network(
                    image,
                    color: accentColor,
                    fit: BoxFit.contain,
                    placeholderBuilder: (BuildContext context) => Container(
                        child: CircleAvatar(child: CircularProgressIndicator(), backgroundColor: Colors.white,)),
                  ),
                  margin: EdgeInsets.all(5.0),
                ),
                MontserratText(
                  "$text",
                  16,
                  separatorColor,
                  FontWeight.bold,
                  left: 16.0,
                )
//                Container(
//                  margin:
//                      EdgeInsets.only(left: mediaQueryData.size.width * 0.05),
//                  child: AutoSizeText(
//                    text,
//                    style: TextStyle(
//                        fontFamily: 'Montserrat',
//                        fontWeight: FontWeight.bold,
//                        fontSize: 16.0),
//                  ),
//                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//class MyPainter extends CustomPainter {
//  final Path path;
//  final Color color;
//  final bool showPath;
//  MyPainter(this.path, this.color, {this.showPath = true});
//
//  @override
//  void paint(Canvas canvas, Size size) {
//    var paint = Paint()
//      ..color = color
//      ..strokeWidth = 4.0;
//    canvas.drawPath(path, paint);
//    if (showPath) {
//      var border = Paint()
//        ..color = Colors.black
//        ..strokeWidth = 1.0
//        ..style = PaintingStyle.stroke;
//      canvas.drawPath(path, border);
//    }
//  }
//
//  @override
//  bool shouldRepaint(CustomPainter oldDelegate) => true;
//}
