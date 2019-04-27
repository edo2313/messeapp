//WORK IN PROGRESS

import 'package:flutter/material.dart';

class DeskEditor extends CustomPainter {
  List<List<int>> desks = [
    [3,3,3],
    [2,2,2,2],
    [3,3,3,2]
  ];

  @override
  void paint(Canvas canvas, Size size) {
    Paint stroke = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white); // serve solo per evidenziare la canvas in fase di sviluppo
    const int separation = 2; // costanti per definire i rapporti fra larghezza e altezza dei banchi e gli spazi fra i blocchi
    const int height = 6;
    const int width = 8;
    Size s;

    // determinare se effettuare il ridimensionamento orizzontale o verticale
    int horizontalWeight = separation*(desks.length+1);
    desks.forEach((l) => horizontalWeight += width*l.fold(0, (max, i) => max<i ? i : max));
    int verticalWeight = desks.fold(0, (max, i) => max<i.length ? i.length : max);
    verticalWeight = separation*(verticalWeight+1)+height*verticalWeight;

    if (horizontalWeight/verticalWeight < size.width/size.height)
      s = Size(horizontalWeight*size.height/verticalWeight, size.height);
    else
      s = Size(size.width, verticalWeight*size.width/horizontalWeight);
    //

    double deskWidth = s.width/horizontalWeight*width;

    double hCenter = (size.width-s.width)/2;
    desks.forEach(
        (column) {
          int max = column.fold(0, (m, i) => m<i? i : m);
          hCenter += deskWidth*(separation/width+max/2);
          double vCenter = (size.height)/2+deskWidth*(column.length-1)*(height/width+separation/width)/2;
          column.forEach(
              (row) {
                double hCenter2 = hCenter-(row-1)*deskWidth/2;
                for (int i=0; i<row; i++, hCenter2 += deskWidth)
                  canvas.drawRect(
                      Rect.fromLTWH(hCenter2-deskWidth/2, vCenter-deskWidth/2, deskWidth, deskWidth*height/width),
                      stroke
                  );
                vCenter -= deskWidth*(height/width+separation/width);
              }
          );
          hCenter += deskWidth*max/2;
        }
    );

    // TODO: aggiungere la possibilità di modificare la disposizione
    // TODO: scrivere i numeri di registro in ordine randomico

    TextPainter p = TextPainter(
      text: TextSpan(text: 'Work in progress', style: TextStyle(color: Colors.black)),
      textDirection: TextDirection.ltr,
      //textAlign: TextAlign.center,
    );
    p.layout();
    p.paint(canvas, Offset(10, size.height-20));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }

}