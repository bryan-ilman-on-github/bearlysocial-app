import 'package:bearlysocial/views/lines/progress_spinner.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SafeArea(
        child: Center(
          child: ProgressSpinner(),
        ),
      ),
    );
  }
}
