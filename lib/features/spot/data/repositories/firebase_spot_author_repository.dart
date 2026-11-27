import 'package:spotshare/core/error/firebase_failure.dart';
import 'package:spotshare/features/spot/data/datasources/spot_author_remote_data_source.dart';
import 'package:spotshare/features/spot/data/mappers/spot_author_mapper.dart';
import 'package:spotshare/features/spot/domain/entities/spot_author.dart';
import 'package:spotshare/features/spot/domain/repositories/spot_author_repository.dart';

class FirebaseSpotAuthorRepository implements SpotAuthorRepository {
  const FirebaseSpotAuthorRepository(this._remote);

  final SpotAuthorRemoteDataSource _remote;

  @override
  Stream<SpotAuthor?> watchAuthor(String userId) => _remote
      .watchAuthor(userId)
      .map((dto) => dto?.toEntity())
      .handleError((Object e) => throw failureFrom(e));
}
