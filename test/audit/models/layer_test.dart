import 'package:flutter_test/flutter_test.dart';
import 'package:todo_cleanarc/audit/models/layer.dart';

void main() {
  group('Layer enum', () {
    test('should have all expected layer values', () {
      expect(Layer.values, hasLength(5));
      expect(Layer.values, contains(Layer.pages));
      expect(Layer.values, contains(Layer.operations));
      expect(Layer.values, contains(Layer.miscellaneous));
      expect(Layer.values, contains(Layer.domain));
      expect(Layer.values, contains(Layer.infrastructure));
    });
  });
}
