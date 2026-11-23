import 'package:flutter/material.dart';
import 'package:spotshare/core/theme/app_theme.dart';
import 'package:spotshare/features/spot/domain/entities/spot.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_address_row.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_author_label.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_category_chip.dart';
import 'package:spotshare/features/spot/presentation/widgets/spot_rating_summary.dart';

class SpotHeader extends StatelessWidget {
  const SpotHeader({super.key, required this.spot});

  final Spot spot;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final gap = SizedBox(height: theme.spacing.spacingS);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(spot.title, style: theme.textStyles.h2),
        gap,
        Wrap(
          spacing: theme.spacing.spacingS,
          runSpacing: theme.spacing.spacingXs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SpotCategoryChip(category: spot.category),
            SpotRatingSummary(spotId: spot.id),
          ],
        ),
        gap,
        SpotAddressRow(address: spot.address),
        gap,
        SpotAuthorLabel(authorId: spot.authorId),
      ],
    );
  }
}
