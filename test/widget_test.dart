import 'package:flutter_test/flutter_test.dart';
import 'package:vix/explorer/models/service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Your tests go here.
  test('libDirectory', () async {
    final list = await listDirectory('.');
    print(list);
  });
}
