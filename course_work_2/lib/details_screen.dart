import 'package:flutter/material.dart';
import '../recipe.dart';

class DetailsScreen extends StatelessWidget {
  final Recipe recipe;

  DetailsScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...recipe.ingredients.map((ingredient) => Text('• $ingredient')),
            SizedBox(height: 16),
            Text('Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(recipe.instructions),
          ],
        ),
      ),
    );
  }
}
