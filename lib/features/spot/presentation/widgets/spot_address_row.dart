import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotAddressRow extends StatelessWidget {
  const SpotAddressRow({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final t = context.t.spot;
    return Row(
      children: [
        Icon(
          Icons.place_outlined,
          size: theme.spacing.spacingM,
          color: theme.colors.foregroundMuted,
        ),
        SizedBox(width: theme.spacing.spacingXs),
        Expanded(child: Text(address, style: theme.textStyles.b2)),
        IconButton(
          tooltip: t.copyAddress,
          icon: const Icon(Icons.copy),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await Clipboard.setData(ClipboardData(text: address));
            messenger.showSnackBar(SnackBar(content: Text(t.addressCopied)));
          },
        ),
      ],
    );
  }
}
