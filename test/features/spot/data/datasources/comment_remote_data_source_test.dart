import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/data/datasources/comment_remote_data_source.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CommentRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = CommentRemoteDataSource(firestore);
  });

  Future<void> seed(String id, int day) =>
      firestore.doc('spots/s1/comments/$id').set({
        'authorId': 'u1',
        'text': 'texte $id',
        'createdAt': Timestamp.fromDate(DateTime(2026, 11, day)),
      });

  test(
    'liste les commentaires du plus récent au plus ancien, limités',
    () async {
      await seed('c1', 1);
      await seed('c2', 3);
      await seed('c3', 2);

      final comments = await dataSource.watchComments('s1', 2).first;

      expect(comments.map((c) => c.id), ['c2', 'c3']);
    },
  );

  test(
    'ajoute un commentaire avec l’auteur, le texte et la date serveur',
    () async {
      await dataSource.addComment('s1', 'u1', 'Super spot');

      final docs = (await firestore.collection('spots/s1/comments').get()).docs;
      expect(docs, hasLength(1));
      expect(
        docs.single.data().keys,
        unorderedEquals(['authorId', 'text', 'createdAt']),
      );
      expect(docs.single.data()['authorId'], 'u1');
      expect(docs.single.data()['text'], 'Super spot');
      expect(docs.single.data()['createdAt'], isA<Timestamp>());
    },
  );

  test('supprime le commentaire', () async {
    await seed('c1', 1);

    await dataSource.deleteComment('s1', 'c1');

    expect((await firestore.doc('spots/s1/comments/c1').get()).exists, isFalse);
  });
}
