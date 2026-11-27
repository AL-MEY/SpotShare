import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/core/network/connectivity_provider.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/core/widgets/error_bottom_sheet.dart';
import 'package:spotshare/core/widgets/loading_button.dart';
import 'package:spotshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';
import 'package:spotshare/features/spot/presentation/providers/spot_providers.dart';
import 'package:spotshare/i18n/strings.g.dart';

class CommentComposer extends ConsumerStatefulWidget {
  const CommentComposer({super.key, required this.spotId});

  final String spotId;

  @override
  ConsumerState<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<CommentComposer> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final length = (value ?? '').trim().length;
    final t = context.t.spot.comments;
    if (length == 0) return t.empty;
    if (length > SpotComment.maxLength) {
      return t.tooLong(max: SpotComment.maxLength);
    }
    return null;
  }

  void _send(String userId) {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(commentComposerControllerProvider.notifier)
        .submit(
          () => ref.read(addCommentProvider)(
            spotId: widget.spotId,
            authorId: userId,
            text: _controller.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.spot;
    final theme = context.appTheme;
    final userId = ref.watch(currentUserIdProvider);
    final online = ref.watch(isOnlineProvider).value ?? true;
    final sending = ref.watch(commentComposerControllerProvider).isLoading;
    ref.listen(commentComposerControllerProvider, (previous, next) {
      if (next is AsyncData && (previous?.isLoading ?? false)) {
        // reset vide aussi l'erreur de validation affichée.
        _formKey.currentState?.reset();
      }
      final error = next.error;
      if (error is Failure) showErrorBottomSheet(context, error);
    });
    if (userId == null) return const SizedBox.shrink();

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: theme.spacing.spacingS,
        children: [
          TextFormField(
            controller: _controller,
            enabled: online && !sending,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: online ? t.comments.hint : t.offline,
            ),
            validator: _validate,
          ),
          LoadingButton(
            label: t.comments.send,
            isLoading: sending,
            onPressed: online ? () => _send(userId) : null,
          ),
        ],
      ),
    );
  }
}
