import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/i18n/strings.g.dart';

class SpotDescription extends StatefulWidget {
  const SpotDescription({super.key, required this.text});

  static const collapsedLines = 5;

  final String text;

  @override
  State<SpotDescription> createState() => _SpotDescriptionState();
}

class _SpotDescriptionState extends State<SpotDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final t = context.t.spot;
    final style = theme.textStyles.b1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: SpotDescription.collapsedLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: style,
              maxLines: _expanded ? null : SpotDescription.collapsedLines,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (overflows)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? t.readLess : t.readMore),
              ),
          ],
        );
      },
    );
  }
}
