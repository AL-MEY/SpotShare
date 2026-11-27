import 'package:spotshare/features/spot/data/models/spot_author_dto.dart';
import 'package:spotshare/features/spot/domain/entities/spot_author.dart';

extension SpotAuthorDtoMapper on SpotAuthorDto {
  SpotAuthor toEntity() =>
      SpotAuthor(id: id, displayName: displayName, avatarUrl: avatarUrl);
}
