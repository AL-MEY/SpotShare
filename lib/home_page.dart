import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/spot/presentation/widgets/recent_spots_list.dart';
import 'package:spotshare/i18n/strings.g.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.home;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.welcome),
        actions: [
          IconButton(
            onPressed: () => ref.read(signOutProvider)(),
            tooltip: t.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      // Liste temporaire : remplacée par le flux (§2.2).
      body: const RecentSpotsList(),
    );
  }
}
