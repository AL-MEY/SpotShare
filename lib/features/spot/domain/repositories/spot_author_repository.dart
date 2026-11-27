import 'package:spotshare/features/spot/domain/entities/spot_author.dart';

abstract interface class SpotAuthorRepository {
  Stream<SpotAuthor?> watchAuthor(String userId);
}
