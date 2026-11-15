import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/profile/presentation/providers/profile_providers.dart';
import 'package:spotshare/features/profile/presentation/widgets/profile_load_error.dart';

class ProfileLoadingPage extends ConsumerWidget {
  const ProfileLoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedSwitcher(
            duration: kThemeAnimationDuration,
            child: switch (ref.watch(currentProfileProvider)) {
              AsyncError(:final Failure error) => ProfileLoadError(
                failure: error,
              ),
              _ => const CircularProgressIndicator(),
            },
          ),
        ),
      ),
    );
  }
}
