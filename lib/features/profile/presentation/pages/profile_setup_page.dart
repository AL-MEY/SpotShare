import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/widgets/error_bottom_sheet.dart';
import 'package:spotshare/core/widgets/loading_button.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/profile/domain/entities/user_profile.dart';
import 'package:spotshare/features/profile/presentation/providers/profile_providers.dart';
import 'package:spotshare/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:spotshare/features/profile/presentation/widgets/bio_field.dart';
import 'package:spotshare/features/profile/presentation/widgets/display_name_field.dart';
import 'package:spotshare/i18n/strings.g.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayName = TextEditingController();
  final _bio = TextEditingController();

  @override
  void dispose() {
    _displayName.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final saveProfile = ref.read(saveProfileProvider);
    final profile = UserProfile(
      id: userId,
      displayName: _displayName.text,
      bio: _bio.text,
    );
    final avatarPath = ref.read(pickedAvatarProvider);
    ref
        .read(profileSetupControllerProvider.notifier)
        .submit(() => saveProfile(profile, avatarPath: avatarPath));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.profile;
    final theme = context.appTheme;
    ref.listen(profileSetupControllerProvider, (_, next) {
      if (next case AsyncError(:final Failure error)) {
        showErrorBottomSheet(context, error, onRetry: _submit);
      }
    });
    final isLoading = ref.watch(profileSetupControllerProvider).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.setupTitle),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => ref.read(signOutProvider)(),
            child: Text(t.signOut),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacing.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: theme.spacing.spacingS,
              children: [
                Text(
                  t.setupHint,
                  style: theme.textStyles.b1.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const AvatarPicker(),
                DisplayNameField(controller: _displayName),
                BioField(controller: _bio),
                LoadingButton(
                  label: t.setupSubmit,
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
