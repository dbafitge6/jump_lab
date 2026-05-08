import 'database_helper.dart';

Future<void> addTestData() async {
  final records = [
    JumpRecord(date: DateTime.now().subtract(const Duration(days: 6)), jump1: 20.0, jump2: 22.0, jump3: 21.0, average: 21.0, best: 22.0),
    JumpRecord(date: DateTime.now().subtract(const Duration(days: 5)), jump1: 23.0, jump2: 25.0, jump3: 24.0, average: 24.0, best: 25.0),
    JumpRecord(date: DateTime.now().subtract(const Duration(days: 4)), jump1: 24.0, jump2: 26.0, jump3: 25.0, average: 25.0, best: 26.0),
    JumpRecord(date: DateTime.now().subtract(const Duration(days: 3)), jump1: 25.0, jump2: 27.0, jump3: 26.0, average: 26.0, best: 27.0),
    JumpRecord(date: DateTime.now().subtract(const Duration(days: 2)), jump1: 27.0, jump2: 29.0, jump3: 28.0, average: 28.0, best: 29.0),
    JumpRecord(date: DateTime.now().subtract(const Duration(days: 1)), jump1: 28.0, jump2: 30.0, jump3: 29.0, average: 29.0, best: 30.0),
  ];
  for (final r in records) {
    await DatabaseHelper.instance.insertRecord(r);
  }
}
