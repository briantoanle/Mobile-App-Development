import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DrawingApp(),
    );
  }
}

class DrawingApp extends StatefulWidget {
  @override
  _DrawingAppState createState() => _DrawingAppState();
}

class _DrawingAppState extends State<DrawingApp> {
  List<List<Offset>> lines = []; // Use a list of lists for each line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing App'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition =
                renderBox.globalToLocal(details.globalPosition);
            if (lines.isEmpty || lines.last.isEmpty) {
              lines.add([localPosition]);
            } else {
              lines.last.add(localPosition);
            }
          });
        },
        onPanEnd: (_) {
          setState(() {
            lines.add([]);
          });
        },
        child: CustomPaint(
          painter: MyPainter(lines),
          size: Size.infinite,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            lines.clear();
          });
        },
        child: Icon(Icons.clear),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<List<Offset>> lines;

  MyPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (final line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }

    // my emoji
    Paint facePaint = Paint()..color = Colors.yellow;
    final faceRadius = size.width / 2;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      faceRadius,
      facePaint,
    );

    Paint eyePaint = Paint()..color = Colors.black;
    final eyeRadius = faceRadius / 5;
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.4),
      eyeRadius,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.4),
      eyeRadius,
      eyePaint,
    );
