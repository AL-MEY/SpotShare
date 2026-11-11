import 'package:flutter/material.dart';
import 'package:spotshare/i18n/strings.g.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(context.t.login.title)));
  }
}
