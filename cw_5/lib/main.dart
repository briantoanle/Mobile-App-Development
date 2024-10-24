import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(MaterialApp(home: AquariumApp()));
}

class Fish {
  Offset position;
  Color color;
  double speed;
  double angle;

  Fish({required this.position, required this.color, required this.speed})
      : angle = math.Random().nextDouble() * 2 * math.pi;
}

class AquariumApp extends StatefulWidget {
  @override
  _AquariumAppState createState() => _AquariumAppState();
}

class _AquariumAppState extends State<AquariumApp>
    with TickerProviderStateMixin {
  List<Fish> fishList = [];
  late AnimationController _controller;
  Color selectedColor = Colors.orange;
  double selectedSpeed = 100;
  final double aquariumSize = 300;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
    _controller.addListener(_updateFishPositions);
    // Add initial fish
    _addFish();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(
          position: Offset(
            math.Random().nextDouble() * (aquariumSize - 20) + 10,
            math.Random().nextDouble() * (aquariumSize - 20) + 10,
          ),
          color: selectedColor,
          speed: selectedSpeed,
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum number of fish (10) reached!')));
    }
  }

  void _removeFish() {
    if (fishList.isNotEmpty) {
      setState(() {
        fishList.removeLast();
      });
    }
  }

  void _updateFishPositions() {
    setState(() {
      for (var fish in fishList) {
        // Calculate new position
        double dx = math.cos(fish.angle) * (fish.speed / 1000);
        double dy = math.sin(fish.angle) * (fish.speed / 1000);
        Offset newPosition = fish.position.translate(dx, dy);

        // Check for collisions with walls
        if (newPosition.dx < 10 || newPosition.dx > aquariumSize - 10) {
          fish.angle = math.pi - fish.angle;
        }
        if (newPosition.dy < 10 || newPosition.dy > aquariumSize - 10) {
          fish.angle = -fish.angle;
        }

        // Update position
        fish.position = Offset(
          newPosition.dx.clamp(10, aquariumSize - 10),
          newPosition.dy.clamp(10, aquariumSize - 10),
        );

        // Occasionally change direction randomly
        if (math.Random().nextDouble() < 0.02) {
          fish.angle += (math.Random().nextDouble() - 0.5) * math.pi / 2;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Aquarium'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fish counter
            Text(
              'Fish: ${fishList.length}/10',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Aquarium container
            Container(
              width: aquariumSize,
              height: aquariumSize,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  for (var fish in fishList)
                    Positioned(
                      left: fish.position.dx - 10,
                      top: fish.position.dy - 10,
                      child: Transform.rotate(
                        angle: fish.angle,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: fish.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Controls
            Container(
              width: aquariumSize,
              child: Column(
                children: [
                  // Fish control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addFish,
                        icon: Icon(Icons.add),
                        label: Text('Add Fish'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _removeFish,
                        icon: Icon(Icons.remove),
                        label: Text('Remove Fish'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Speed control
                  Text('Swimming Speed',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: selectedSpeed,
                    min: 50,
                    max: 200,
                    divisions: 15,
                    label: selectedSpeed.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        selectedSpeed = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  // Color selection
                  Text('Fish Color',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Colors.orange,
                      Colors.red,
                      Colors.green,
                      Colors.yellow,
                      Colors.purple,
                    ]
                        .map((Color color) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor == color
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
