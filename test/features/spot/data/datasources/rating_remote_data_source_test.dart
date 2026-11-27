import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/datasources/rating_remote_data_source.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late RatingRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = RatingRemoteDataSource(firestore);
  });

  test('écrit la note dans ratings/{uid} avec la valeur et la date', () async {
    await dataSource.setRating('s1', 'u1', 4);

    final doc = await firestore.doc('spots/s1/ratings/u1').get();
    expect(doc.data()?.keys, unorderedEquals(['value', 'updatedAt']));
    expect(doc.data()?['value'], 4);
    expect(doc.data()?['updatedAt'], isA<Timestamp>());
  });

  test('émet null quand l’utilisateur n’a pas noté', () async {
    expect(await dataSource.watchRating('s1', 'u1').first, isNull);
  });

  test('émet la nouvelle note après écriture', () async {
    final emitted = expectLater(
      dataSource.watchRating('s1', 'u1'),
      emitsInOrder([isNull, 3]),
    );

    await dataSource.setRating('s1', 'u1', 3);

    await emitted;
  });

  test('une valeur stockée non numérique est lue comme absente', () async {
    await firestore.doc('spots/s1/ratings/u1').set({'value': 'cinq'});

    expect(await dataSource.watchRating('s1', 'u1').first, isNull);
  });
}
