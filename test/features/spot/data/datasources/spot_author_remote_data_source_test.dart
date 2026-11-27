import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/datasources/spot_author_remote_data_source.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SpotAuthorRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = SpotAuthorRemoteDataSource(firestore);
  });

  test('lit le nom et l’avatar de l’auteur', () async {
    await firestore.doc('users/u1').set({
      'displayName': 'Alice',
      'avatarUrl': 'https://example.com/a.jpg',
    });

    final dto = await dataSource.watchAuthor('u1').first;

    expect(dto?.displayName, 'Alice');
    expect(dto?.avatarUrl, 'https://example.com/a.jpg');
  });

  test('émet null quand l’auteur n’a pas de profil', () async {
    expect(await dataSource.watchAuthor('absent').first, isNull);
  });
}
