import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  Color petColor = Colors.yellow;
  String petMood = "Neutral";
  bool isGameOver = false;
  bool hasWon = false;
  Timer? hungerTimer;
  Timer? winTimer;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startHungerTimer();
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    winTimer?.cancel();
    nameController.dispose();
    super.dispose();
  }

  void startHungerTimer() {
    hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        updatePetStatus();
      });
    });
  }

  void startWinTimer() {
    winTimer = Timer(Duration(minutes: 3), () {
      if (happinessLevel > 80) {
        setState(() {
          hasWon = true;
        });
      }
    });
  }

  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      updatePetStatus();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      updatePetStatus();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    updatePetStatus();
  }

  void updatePetStatus() {
    if (happinessLevel > 70) {
      petColor = Colors.green;
      petMood = "Happy";
    } else if (happinessLevel >= 30) {
      petColor = Colors.yellow;
      petMood = "Neutral";
    } else {
      petColor = Colors.red;
      petMood = "Unhappy";
    }

    if (hungerLevel >= 100 && happinessLevel <= 10) {
      isGameOver = true;
    }

    if (happinessLevel > 80 && !hasWon) {
      startWinTimer();
    } else {
      winTimer?.cancel();
    }
  }

  void setCustomName() {
    if (nameController.text.isNotEmpty) {
      setState(() {
        petName = nameController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isGameOver)
              Text(
                'Game Over!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              )
            else if (hasWon)
              Text(
                'You Won!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              )
            else ...[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: petColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Name: $petName',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Happiness Level: $happinessLevel',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Hunger Level: $hungerLevel',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Mood: $petMood ${_getMoodEmoji()}',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _playWithPet,
                child: Text('Play with Your Pet'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _feedPet,
                child: Text('Feed Your Pet'),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter pet name',
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: setCustomName,
                    child: Text('Set Name'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji() {
    switch (petMood) {
      case 'Happy':
        return '😃';
      case 'Neutral':
        return '😐';
      case 'Unhappy':
        return '😢';
      default:
        return '';
    }
  }
}
