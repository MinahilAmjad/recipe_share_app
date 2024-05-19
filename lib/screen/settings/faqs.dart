import 'package:flutter/material.dart';

class Recipe_Creationfaq extends StatelessWidget {
  const Recipe_Creationfaq({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 232, 228, 228),

        title: Text('Recipe Sharing FAQ'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FAQItem(
                question: 'How do I share my recipe?',
                answer:
                    'To share your recipe, navigate to the recipe creation screen and fill in all the required details such as title, ingredients, and instructions. Once you have completed the form, you can choose to share the recipe publicly or with specific users.',
              ),
              Divider(),
              FAQItem(
                question: 'Can I edit or delete a recipe after sharing it?',
                answer:
                    'Yes, you can edit or delete a recipe after sharing it. Simply navigate to your profile or the recipe details screen and select the option to edit or delete the recipe. Any changes you make will be reflected immediately.',
              ),
              Divider(),
              FAQItem(
                question: 'How can I view recipes shared by other users?',
                answer:
                    'You can view recipes shared by other users by browsing the recipe feed or using the search functionality to find specific recipes. You can also follow other users to see their latest recipe creations.',
              ),
              Divider(),
              FAQItem(
                question:
                    'Is there a limit to the number of recipes I can share?',
                answer:
                    'No, there is no limit to the number of recipes you can share. You can share as many recipes as you like and even create recipe collections to organize your recipes.',
              ),
              Divider(),
              FAQItem(
                question: 'Can I report inappropriate or offensive recipes?',
                answer:
                    'Yes, if you come across an inappropriate or offensive recipe, you can report it to the platform administrators. Simply navigate to the recipe details screen and select the option to report the recipe.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({
    required this.question,
    required this.answer,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          answer,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}
