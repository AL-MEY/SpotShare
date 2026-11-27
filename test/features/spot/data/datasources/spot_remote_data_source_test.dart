import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/datasources/spot_remote_data_source.dart';

Map<String, dynamic> _data(String title, DateTime createdAt) => {
  'title': title,
  'description': 'desc',
  'category': 'cafe',
  'address': 'adresse',
  'location': const GeoPoint(48.85, 2.35),
  'media': <Map<String, dynamic>>[],
  'tags': <String>[],
  'authorId': 'author',
  'createdAt': Timestamp.fromDate(createdAt),
};

void main() {
  late FakeFirebaseFirestore firestore;
  late SpotRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = SpotRemoteDataSource(firestore);
  });

  test('émet le spot quand il existe', () async {
    await firestore
        .collection('spots')
        .doc('s1')
        .set(_data('Café', DateTime(2026, 11)));

    final doc = await dataSource.watchSpot('s1').first;

    expect(doc.dto?.id, 's1');
    expect(doc.dto?.title, 'Café');
  });

  test('émet un document vide quand le spot n’existe pas', () async {
    final doc = await dataSource.watchSpot('absent').first;

    expect(doc.dto, isNull);
  });

  test(
    'liste les spots récents du plus récent au plus ancien, limitée',
    () async {
      for (final (id, day) in [('a', 1), ('b', 3), ('c', 2)]) {
        await firestore
            .collection('spots')
            .doc(id)
            .set(_data(id, DateTime(2026, 11, day)));
      }

      final spots = await dataSource.watchRecentSpots(2).first;

      expect(spots.map((s) => s.id), ['b', 'c']);
    },
  );
}
