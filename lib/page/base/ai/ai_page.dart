import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_service.dart';
import '../../../utils/colors.dart';
import '../my_course/ai_quiz_page.dart';

class AiPage extends StatefulWidget {
  const AiPage({Key? key}) : super(key: key);

  @override
  _AIPageState createState() => _AIPageState();
}

class _AIPageState extends State<AiPage> {
  final TextEditingController _topicController = TextEditingController();
  bool _isGenerating = false;

  final ApiService apiService = ApiService();
  String get domainURL => apiService.domainUrl;
  String token = "";

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    await loadUser();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenString = prefs.getString('token');
      if (tokenString != null) {
        token = tokenString;
      }

      setState(() {
        // context.loaderOverlay.show();
      });
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        // context.loaderOverlay.hide();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.robot,
              color: Colors.white,
            ),
            const SizedBox(width: 8), // Space between the icon and text
            Text(
              ' | Generate MCQ Quiz Using AI',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ), // Rounded corners
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Generate Quiz Using AI',
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // const SizedBox(height: 20),

            // Input field
            TextField(
              controller: _topicController,
              maxLength: 40,
              decoration: InputDecoration(
                labelText: 'Enter Topic/Subject',
                hintText: 'e.g., Solar System, World War II',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: const Icon(FontAwesomeIcons.book, color: AppColors.primary,),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to use:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildInstructionItem(
                      '1. Enter a specific topic or subject (max 40 characters)',
                      FontAwesomeIcons.pencil,
                      AppColors.tertiary
                  ),
                  _buildInstructionItem(
                      '2. Be clear and concise with your topic',
                      FontAwesomeIcons.lightbulb,
                      AppColors.secondary
                  ),
                  _buildInstructionItem(
                      '3. Avoid broad or vague subjects',
                      FontAwesomeIcons.triangleExclamation,
                      Colors.red
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Limitations
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tertiary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Limitations:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiary
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Questions are generated based on available data, using gpt-3.5-turbo model'),
                  Text('• Accuracy may vary depending on the topic'),
                  Text('• Some topics might not generate optimal results'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Disclaimer:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The quiz content is generated by AI and should be used for practice purposes only. While we strive for accuracy, the information provided may not always be 100% accurate or up-to-date.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating
                    ? null
                    : () async {
                  if (_topicController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a topic'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // Handle generation
                  // Navigator.push(...) to your quiz page
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIQuizPage(content: _topicController.text.trim(),),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary, // Button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  _isGenerating ? 'Generating...' : 'Generate Quiz',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}