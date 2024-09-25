import 'package:flutter/material.dart';
import '../recipe.dart';
import 'details_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Recipe> recipes = [
    Recipe(
      name: 'Spaghetti Carbonara',
      ingredients: [
        'Spaghetti',
        'Eggs',
        'Pancetta',
        'Parmesan cheese',
        'Black pepper'
      ],
      instructions:
          '1. Cook pasta\n2. Fry pancetta\n3. Mix eggs and cheese\n4. Combine all ingredients',
    ),
    Recipe(
      name: 'Chicken Curry',
      ingredients: [
        'Chicken',
        'Curry powder',
        'Coconut milk',
        'Onions',
        'Garlic'
      ],
      instructions:
          '1. Sauté onions and garlic\n2. Add chicken and curry powder\n3. Pour in coconut milk\n4. Simmer until chicken is cooked',
    ),
    // Add more recipes here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Book'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recipes[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(recipe: recipes[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
