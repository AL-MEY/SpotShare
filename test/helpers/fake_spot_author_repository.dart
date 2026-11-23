import 'dart:async';

import 'package:spotshare/core/error/failure.dart';
import 'package:spotshare/features/spot/domain/entities/spot_author.dart';
import 'package:spotshare/features/spot/domain/repositories/spot_author_repository.dart';

class FakeSpotAuthorRepository implements SpotAuthorRepository {
  FakeSpotAuthorRepository([this._author = author]);

  static const author = SpotAuthor(id: 'author', displayName: 'Camille');

  SpotAuthor? _author;
  Failure? failure;
  final _controller = StreamController<SpotAuthor?>.broadcast();

  Future<void> dispose() => _controller.close();

  void emit(SpotAuthor? author) {
    _author = author;
    _controller.add(author);
  }

  @override
  Stream<SpotAuthor?> watchAuthor(String userId) async* {
    final failure = this.failure;
    if (failure != null) throw failure;
    yield _author;
    yield* _controller.stream;
  }
}
