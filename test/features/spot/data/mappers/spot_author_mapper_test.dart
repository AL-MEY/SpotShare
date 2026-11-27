import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/mappers/spot_author_mapper.dart';
import 'package:spotshare/features/spot/data/models/spot_author_dto.dart';
import 'package:spotshare/features/spot/domain/entities/spot_author.dart';

void main() {
  test('convertit le DTO en entité', () {
    const dto = SpotAuthorDto(
      id: 'u1',
      displayName: 'Alice',
      avatarUrl: 'https://example.com/a.jpg',
    );

    expect(
      dto.toEntity(),
      const SpotAuthor(
        id: 'u1',
        displayName: 'Alice',
        avatarUrl: 'https://example.com/a.jpg',
      ),
    );
  });
}
