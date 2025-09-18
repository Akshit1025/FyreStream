import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyrestream/theme_data/default.dart';

class DownloadsView extends StatelessWidget {
  const DownloadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        title: Text(
          'Downloads',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: const Center(child: Text('GeeksForGeeks')),
    );
  }
}
