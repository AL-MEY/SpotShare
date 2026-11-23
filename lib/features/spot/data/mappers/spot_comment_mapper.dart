import 'package:spotshare/features/spot/data/models/spot_comment_dto.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';

extension SpotCommentDtoMapper on SpotCommentDto {
  SpotComment toEntity() =>
      SpotComment(id: id, authorId: authorId, text: text, createdAt: createdAt);
}
