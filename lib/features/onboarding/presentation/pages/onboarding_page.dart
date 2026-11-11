import 'package:flutter/material.dart';
import 'package:spotshare/i18n/strings.g.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(context.t.onboarding.title)));
  }
}
