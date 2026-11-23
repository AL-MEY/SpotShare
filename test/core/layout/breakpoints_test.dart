import 'package:flutter_test/flutter_test.dart';
import 'package:spotshare/core/layout/breakpoints.dart';

void main() {
  test(
    'les seuils 599, 600, 839, 840 donnent compact, medium, medium, expanded',
    () {
      expect(WindowSize.fromWidth(599), WindowSize.compact);
      expect(WindowSize.fromWidth(600), WindowSize.medium);
      expect(WindowSize.fromWidth(839), WindowSize.medium);
      expect(WindowSize.fromWidth(840), WindowSize.expanded);
    },
  );
}
