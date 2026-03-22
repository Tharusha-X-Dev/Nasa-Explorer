import 'package:flutter/material.dart';

import '../widgets/section_heading_widget.dart';

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
            'NASA Explorer is a cross-platform mobile application built using Flutter that allows users to explore space images and videos from NASA’s public APIs. The app provides access to the Astronomy Picture of the Day, allows searching NASA’s image library, and lets users save favorite space media for later viewing.',
            style: TextStyle(height: 1.5),
          ),
          SizedBox(height: 22),
          SectionHeadingWidget(text: 'Features', fontSize: 18),
          SizedBox(height: 8),
          Text('• View the Astronomy Picture of the Day (APOD)'),
          SizedBox(height: 4),
          Text('• Search NASA’s image and video library'),
          SizedBox(height: 4),
          Text('• Explore popular space topics'),
          SizedBox(height: 4),
          Text('• Save favorite space content locally'),
          SizedBox(height: 4),
          Text('• Watch NASA space videos'),
          SizedBox(height: 22),
          SectionHeadingWidget(text: 'Technologies Used', fontSize: 18),
          SizedBox(height: 8),
          Text('• Flutter (Cross-platform mobile framework)'),
          SizedBox(height: 4),
          Text('• NASA Open APIs'),
          SizedBox(height: 4),
          Text('• SharedPreferences for local storage'),
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
            'Data and media are provided by NASA’s public APIs.',
            style: TextStyle(height: 1.4),
          ),
          SizedBox(height: 28),
          Center(child: Text('Version 1.0')),
        ],
      ),
    );
  }
}
