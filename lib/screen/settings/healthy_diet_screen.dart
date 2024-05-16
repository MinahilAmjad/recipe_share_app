import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter/services.dart';

class HealthyDietScreen extends StatelessWidget {
  final List<String> _dietTips = [
    'Eat plenty of fruits and vegetables: They are rich in vitamins, minerals, and fiber.',
    'Choose whole grains over refined grains: Whole grains contain more nutrients and fiber.',
    'Include lean protein sources in your diet: Such as poultry, fish, beans, and nuts.',
    'Limit processed foods and sugary drinks: They are high in unhealthy fats, sugars, and calories.',
    'Drink plenty of water: Stay hydrated throughout the day.',
    'Control portion sizes: Pay attention to serving sizes to avoid overeating.',
    'Cook at home more often: Prepare meals using fresh, wholesome ingredients.',
    'Be mindful of your eating habits: Eat slowly and enjoy your food.',
    'Limit salt and added sugars: Use herbs and spices to flavor your meals instead.',
    'Stay active: Regular physical activity is essential for overall health and well-being.'
  ];

  String _copiedText = '';

  HealthyDietScreen({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
    _copiedText = text;
  }

  void _shareText(BuildContext context, String text) async {
    try {
      await FlutterShare.share(
        title: 'Healthy Diet Tips',
        text: _copiedText.isNotEmpty ? _copiedText : text,
        chooserTitle: 'Share via',
      );
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthy Diet Tips'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _dietTips
              .map((tip) => Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _shareText(context, tip);
                                  },
                                  child: Icon(
                                    Icons.share,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }
}
