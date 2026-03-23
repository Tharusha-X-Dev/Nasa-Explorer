import 'package:flutter/material.dart';

import 'package:version_1_0/core/widgets/section_heading_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About NASA Explorer'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          SectionHeadingWidget(text: 'NASA Explorer'),
          SizedBox(height: 8),
          Text(
            'NASA Explorer is a cross-platform Flutter application that helps users discover NASA space media through a simple and clean mobile experience. The app includes APOD highlights, searchable image content, favorites, and profile-based personalization.',
            style: TextStyle(height: 1.5),
          ),
          SizedBox(height: 22),
          SectionHeadingWidget(text: 'Features', fontSize: 18),
          SizedBox(height: 8),
          Text('• View the Astronomy Picture of the Day (APOD)'),
          SizedBox(height: 4),
          Text('• Search and explore NASA image content'),
          SizedBox(height: 4),
          Text('• Browse popular space topics'),
          SizedBox(height: 4),
          Text('• Save favorites with offline support'),
          SizedBox(height: 4),
          Text('• Manage account, profile, and settings'),
          SizedBox(height: 22),
          SectionHeadingWidget(text: 'Technologies Used', fontSize: 18),
          SizedBox(height: 8),
          Text('• Flutter (Cross-platform mobile framework)'),
          SizedBox(height: 4),
          Text('• Firebase Authentication and Cloud Firestore'),
          SizedBox(height: 4),
          Text('• NASA Open APIs'),
          SizedBox(height: 4),
          Text('• SharedPreferences for local storage and caching'),
          SizedBox(height: 4),
          Text('• Material Design UI'),
          SizedBox(height: 22),
          SectionHeadingWidget(text: 'Developer', fontSize: 18),
          SizedBox(height: 8),
          Text('Developed by: Tharusha Lakshan'),
          SizedBox(height: 4),
          Text('Module: Cross Platform Development'),
          SizedBox(height: 4),
          Text('University: UCLAN'),
          SizedBox(height: 22),
          Text(
            'NASA Explorer is an academic project for the Cross Platform Development module at UCLAN. Data and media are provided by NASA public APIs.',
            style: TextStyle(height: 1.4),
          ),
          SizedBox(height: 28),
          Center(child: Text('Version 1.0')),
        ],
      ),
    );
  }
}
