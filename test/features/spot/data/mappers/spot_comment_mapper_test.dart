import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/mappers/spot_comment_mapper.dart';
import 'package:spotshare/features/spot/data/models/spot_comment_dto.dart';
import 'package:spotshare/features/spot/domain/entities/spot_comment.dart';

void main() {
  test('convertit le DTO en entité', () {
    final createdAt = DateTime(2026, 11);
    final dto = SpotCommentDto(
      id: 'c1',
      authorId: 'u1',
      text: 'Super spot',
      createdAt: createdAt,
    );

    expect(
      dto.toEntity(),
      SpotComment(
        id: 'c1',
        authorId: 'u1',
        text: 'Super spot',
        createdAt: createdAt,
      ),
    );
  });
}
