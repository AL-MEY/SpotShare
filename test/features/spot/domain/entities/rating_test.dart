import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/features/spot/domain/entities/rating.dart';

void main() {
  test('accepte les valeurs de 1 à 5', () {
    expect(Rating(1).value, 1);
    expect(Rating(5).value, 5);
  });

  test('refuse 0 et 6', () {
    expect(() => Rating(0), throwsArgumentError);
    expect(() => Rating(6), throwsArgumentError);
  });

  test('deux notes de même valeur sont égales', () {
    expect(Rating(3), Rating(3));
    expect(Rating(3).hashCode, Rating(3).hashCode);
    expect(Rating(3), isNot(Rating(4)));
  });
}
