import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/profile/presentation/providers/profile_providers.dart';
import 'package:spotshare/features/profile/presentation/widgets/image_source_sheet.dart';
import 'package:spotshare/i18n/strings.g.dart';

class AvatarPicker extends ConsumerWidget {
  const AvatarPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final picked = ref.watch(pickedAvatarProvider);
    return Center(
      child: Semantics(
        button: true,
        label: context.t.profile.changeAvatar,
        child: InkResponse(
          onTap: () => _showSources(context, ref),
          child: CircleAvatar(
            radius: theme.spacing.spacing4xl,
            backgroundColor: theme.colors.surfaceMuted,
            foregroundImage: picked == null ? null : FileImage(File(picked)),
            child: Icon(
              Icons.add_a_photo_outlined,
              color: theme.colors.foregroundMuted,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSources(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (_) => const ImageSourceSheet(),
    );
    if (source == null || !context.mounted) return;
    await ref.read(pickedAvatarProvider.notifier).pick(source);
  }
}
